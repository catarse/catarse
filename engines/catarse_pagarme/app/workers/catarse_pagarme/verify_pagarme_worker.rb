class CatarsePagarme::VerifyPagarmeWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform key
    source = find_source_by_key key
    payment = PaymentEngines.find_payment({ key: key })

    raise "payment not found" unless payment.present?
    raise "source not found" unless source.present? && source.try(:[], "metadata").try(:[], "key") == key

    payment.update(gateway_id: source["id"])
    payment.pagarme_delegator.update_transaction
    payment.pagarme_delegator.change_status_by_transaction source["status"]
  end

  private

  def find_source_by_key key
    ::PagarMe.api_key = CatarsePagarme.configuration.api_key
    request = PagarMe::Request.new('/search', 'GET')
    query = {
      type: 'transaction',
      query: {
        from: 0,
        size: 1,
        query: {
          bool: {
            must: {
              match: {
                "metadata.key" => key
              }
            }
          }
        }
      }.to_json
    }

    request.parameters.merge!(query)
    response = request.run
    response.try(:[], "hits").try(:[], "hits").try(:[], 0).try(:[], "_source")
  end
end
