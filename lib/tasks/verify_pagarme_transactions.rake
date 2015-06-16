desc 'Sync payment_transfers with pagar.me transfers'
task verify_pagarme_transfers: [:environment] do
  PagarMe.api_key = CatarsePagarme.configuration.api_key

  PaymentTransfer.pendings.each do |payment_transfer|
    transfer = PagarMe::Transfer.find_by_id payment_transfer.transfer_id

    if transfer.status == 'transferred' && !payment_transfer.payment.refunded?
      payment_transfer.payment.update_column(:state, 'refunded')
      payment_transfer.payment.update_column(:refunded_at, transfer.try(:funding_estimated_date).try(:to_datetime))
    end

    payment_transfer.update_attribute(:transfer_data, transfer.to_hash)
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
      key = source['metadata'].try(:[], 'key').to_s
      puts "Trying to find by key #{key}"
      p = Payment.where("gateway_id IS NULL AND key = ?", key).first # Só podemos pegar o mesmo pagamento se o gateway_id for nulo para evitar conflito
    end
    p
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
        log = PaymentLog.find_or_initialize_by(gateway_id: source[:id]) do |l|
          l.data = source.to_json
        end
        log.save
        puts "saving not found payment at PaymentLog -> #{log.id}"
      end
    end
  end

  PagarMe.api_key = CatarsePagarme.configuration.api_key

  puts "Verifying all payment from #{args[:start_date]} to #{args[:end_date]}"
  fix_payments(args[:start_date], args[:end_date]) do |source, payment|
    raise "Gateway_id mismatch #{payment.gateway_id} (catarse) != #{source['id']} (pagarme)" if payment.gateway_id.to_s != source['id'].to_s
    puts "Updating #{source['id']}(pagarme) - #{payment.gateway_id}(catarse)..."
    puts "Changing state to #{source['status']}"
    payment.pagarme_delegator.change_status_by_transaction source['status']
    payment.pagarme_delegator.update_transaction
  end
end

