desc "Verify all transactions in pagarme for a given date range and check their consistency in our database"
task :verify_pagarme_transactions, [:start_date, :end_date]  => :environment do |task, args|
  args.with_defaults(start_date: Date.today - 1, end_date: Date.today)
  Rails.logger.info "Verifying transactions in range: #{args.inspect}"

  def find_transactions_by_dates(start_date, end_date, from = 0, size = 50)
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
    Payment.find_by(gateway_id: source['id'].to_s) || Payment.find_by(key: source['metadata'].try(:[], 'key').to_s)
  end

  def find_contribution source
    puts source.inspect
    Contribution.where(payer_email: source['customer']['email'], value: (source['amount']/100.0)).where("(created_at::timestamptz AT TIME ZONE 'America/Sao_Paulo')::date = ?", source['date_created'].to_date).order(:id).last
  end

  def all_transactions(start_date, end_date)
    first_collection = find_transactions_by_dates(start_date, end_date)
    total_pages = first_collection['hits']['total'] / 50
    total_pages.times do |page|
      result = find_transactions_by_dates(start_date, end_date, page)
      result['hits']['hits'].each do |hit|
        _source = hit['_source']
        payment = find_payment _source
        yield _source, payment
      end
    end
  end

  PagarMe.api_key = CatarsePagarme.configuration.api_key

  puts "pagarme_id,pagarme_status,pagarme_value,catarse_id,catarse_state"

  all_transactions(args[:start_date], args[:end_date]) do |source, payment|
    if payment
      puts [source['id'], source['status'], source['amount'],
            payment.try(:amount), payment.try(:gateway_id), payment.try(:state)].join(",")
    else
      puts ">>>>>>>> NAO ENCONTREI O PAGAMENTO!!!!! #{source['id']}"
      contribution = find_contribution source
      puts "Contribution: #{contribution.inspect}"
    end
  end
end

