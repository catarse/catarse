# -*- coding: utf-8 -*-
desc 'Sync payment_transfers with pagar.me transfers'
task verify_pagarme_transfers: [:environment] do
  PagarMe.api_key = CatarsePagarme.configuration.api_key

  PaymentTransfer.pending.each do |payment_transfer|
    transfer = PagarMe::Transfer.find_by_id payment_transfer.transfer_id

    if transfer.status == 'transferred' && !payment_transfer.payment.refunded?
      payment_transfer.payment.update_column(:state, 'refunded')
      payment_transfer.payment.update_column(:refunded_at, transfer.try(:funding_estimated_date).try(:to_datetime))
    end

    payment_transfer.update_attribute(:transfer_data, transfer.to_hash)
  end
end

desc 'Sync balance_transfers with pagar.me transfers'
task verify_balance_transfers: [:environment] do
  PagarMe.api_key = CatarsePagarme.configuration.api_key

  BalanceTransfer.processing.each do |bt|
    transfer = PagarMe::Transfer.find_by_id bt.transfer_id

    case transfer.status
    when 'transferred' then
      bt.transition_to(:transferred, transfer_data: transfer.to_hash)
    when 'failed' then
      bt.transition_to(:error, transfer_data: transfer.to_hash)
    end
  end
end

desc 'Sync user_transfers with pagar.me transfers'
task verify_pagarme_user_transfers: [:environment] do
  PagarMe.api_key = CatarsePagarme.configuration.api_key

  UserTransfer.pending.each do |payment_transfer|
    transfer = PagarMe::Transfer.find_by_id payment_transfer.gateway_id

    payment_transfer.update_column(:status, transfer.status)

    payment_transfer.update_attribute(:transfer_data, transfer.to_hash)
    if transfer.status == 'failed'
      payment_transfer.notify(:invalid_refund, payment_transfer.user)
      if payment_transfer.over_refund_limit?
        backoffice_user = User.find_by(email: CatarseSettings[:email_contact])
        payment_transfer.notify(:over_refund_limit, backoffice_user) if backoffice_user
      end
    end
  end
end

desc "Verify all transactions in pagarme for a given date range and check their consistency in our database"
task :verify_pagarme_transactions, [:start_date, :end_date]  => :environment do |task, args|
  args.with_defaults(start_date: Date.today - 1, end_date: Date.today)
  Rails.logger.info "Verifying transactions in range: #{args.inspect}"
  PAGE_SIZE = 50

  def find_transactions_by_dates(start_date, end_date, from = 0, size = PAGE_SIZE)
    request = PagarMe::Request.new('/search', 'GET')
    query = {
      type: 'transaction',
      query: {
        from: from,
        size: size,
        query: {
          range: {
            date_created: {
              gte: start_date,
              lte: end_date
            }
          }
        }
      }.to_json
    }
    Rails.logger.info query.inspect
    request.parameters.merge!(query)
    request.run
  end

  def find_payment source
    gateway_id = source['id'].to_s
    p = Payment.find_by(gateway_id: gateway_id)
    unless p
      key = find_key source
      puts "Trying to find by key #{key}"
      p = Payment.where("gateway_id IS NULL AND key = ?", key).first # Só podemos pegar o mesmo pagamento se o gateway_id for nulo para evitar conflito
    end
    p
  end

  def find_key source
    source['metadata'].try(:[], 'key').to_s
  end

  def find_contribution source
    id = source['metadata'].try(:[], 'contribution_id').to_s
    if id.present?
      Contribution.find(id)
    else
      project_id = source['metadata'].try(:[], 'project_id').to_s
      attributes = {project_id: project_id, payer_email: source['customer']['email'], value: (source['amount'] / 100)}
      Contribution.find_by(attributes)
    end
  end

  def find_payment_method source
    source['payment_method'] == 'boleto' ? 'BoletoBancario' : 'CartaoDeCredito'
  end

  def all_transactions(start_date, end_date)
    first_collection = find_transactions_by_dates(start_date, end_date)
    total_pages = first_collection['hits']['total'] / PAGE_SIZE
    total_pages.times do |page|
      puts "Loading page #{page} / #{total_pages}..."
      result = find_transactions_by_dates(start_date, end_date, page * PAGE_SIZE)
      result['hits']['hits'].each do |hit|
        _source = hit['_source']
        payment = find_payment _source
        yield _source, payment if _source['status'] != 'processing'
      end
    end
  end

  def fix_payments(start_date, end_date)
    all_transactions(start_date, end_date) do |source, payment|
      puts "Verifying transaction #{source['id']}"
      if payment
        # Caso tenha encontrado o pagamento pela chave mas ele tenha gateway_id nulo nós atualizamos o gateway_id antes de prosseguir
        if payment.gateway_id.nil?
          puts "Updating payment gateway_id to #{source['id']}"
          payment.update_attributes gateway_id: source['id']
        end

        # Atualiza os dados usando o pagarme_delegator caso o status não esteja batendo
        yield(source, payment)
      else
        puts "\n\n>>>>>>>>>   Inserting payment not found in Catarse: #{source.inspect}"
        c = find_contribution source
        if c
          puts "\n\n>>>>>>>>>   FOUND"
          payment = c.payments.new({
            gateway: 'Pagarme', 
            gateway_id: source['id'],
            payment_method: find_payment_method(source),
            value: c.value,
            key: find_key(source)
          })
          payment.generate_key
          payment.save!(validate: false)
          yield(source, payment)
        end
      end
    end
  end

  PagarMe.api_key = CatarsePagarme.configuration.api_key

  puts "Verifying all payment from #{args[:start_date]} to #{args[:end_date]}"
  fix_payments(args[:start_date], args[:end_date]) do |source, payment|
    raise "Gateway_id mismatch #{payment.gateway_id} (catarse) != #{source['id']} (pagarme)" if payment.gateway_id.to_s != source['id'].to_s
    if payment.state != source['status'] && source['status'] != 'waiting_payment'
      puts "Updating #{source['id']}(pagarme) - #{payment.gateway_id}(catarse)..."
      puts "Changing state to #{source['status']}"
      payment.pagarme_delegator.change_status_by_transaction source['status']
    end
    payment.pagarme_delegator.update_transaction
  end
end

