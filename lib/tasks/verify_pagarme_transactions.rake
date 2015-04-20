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
    p = Payment.find_by(gateway_id: source['id'].to_s)
    unless p
      key = source['metadata'].try(:[], 'key').to_s
      puts "Trying to find by key #{key}"
      p = Payment.where("gateway_id IS NULL AND key = ?", key).first # Só podemos pegar o mesmo pagamento se o gateway_id for nulo para evitar conflito
      raise "Gateway_id mismatch #{p.gateway_id} (catarse) != #{source['id']} (pagarme)" if p && p.gateway_id && source['id'] != p.gateway_id
    end
    p
  end

  def find_contribution source
    puts source.inspect
    key = source['metadata'].try(:[], 'key').to_s
    puts "Trying to find contribution by key #{key}"
    c = Contribution.find_by key: key
    return c if c.present? # retorna contribution pela chave se encontrou
    return nil if source['customer'].nil? # senao encontrou pela chave tenta pelo customer
    Contribution.where({
      payer_email: source['customer']['email'],
      value: (source['amount']/100.0)
    }).where("(created_at::timestamptz AT TIME ZONE 'America/Sao_Paulo')::date = ?",
             source['date_created'].to_date).order(:id).last
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

  def create_new_payment(contribution, source)
    Payment.create!({
      contribution: contribution,
      gateway: 'Pagarme',
      gateway_id: source['id'],
      gateway_data: source.merge(created_by_verifier: true),
      payment_method: (source['payment_method'] == 'boleto' ? 'BoletoBancario' : 'CartaoDeCredito'),
      installments: source['installments']
    })
  end

  def status_ok?(payment, source)
    return true if payment.deleted? || payment.chargeback?
    case source['status']
    when 'paid', 'authorized' then
      payment.paid?
    when 'refunded' then
      payment.refunded?
    when 'refused' then
      payment.refused?
    else
      true
    end
  end

  def fix_payments(start_date, end_date)
    not_found = []
    all_transactions(start_date, end_date) do |source, payment|
      puts "Verifying transaction #{source['id']}"
      if payment
        # Atualiza os dados usando o pagarme_delegator caso o status não esteja batendo
        yield(source, payment) unless status_ok?(payment, source)
      else
        contribution = find_contribution source
        if contribution
          # Cria novo pagamento para o apoio e atualiza com dados do pagarme
          puts "Creating new payment for #{contribution.id}..."
          payment = create_new_payment(contribution, source)
          yield(source, payment)
        else
          puts ">>>>>>>> NAO ENCONTREI O APOIO!!!!! #{source['id']}"
          not_found << [source['id'], source['status'], source['amount'], source['customer'].try(:[], "email")].join(",")
        end
      end
    end

    unless not_found.empty?
      puts not_found.join("\n")
      not_found_report_file = File.join(Rails.root, "tmp", "#{Time.now.to_i}_not_found_contributions.csv")
      File.open(not_found_report_file, 'w') do |f|
        f.write(not_found.join("\n"))
        f.close
      end

      puts "use 'cat #{not_found_report_file}' to see the not found contributions"
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

