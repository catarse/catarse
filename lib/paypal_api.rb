class PaypalApi
  class << self
    attr_accessor :username, :password, :signature
    def configure(&block)
      yield self
    end

    def common_params
      {
        :USER => username,
        :PWD => password,
        :SIGNATURE => signature,
        :VERSION => '78.0'
      }
    end

    def endpoint
      'https://api-3t.paypal.com/nvp'
    end

    def transaction_details(transaction_id)
      RestClient.get(endpoint,{
                                :METHOD => 'GetTransactionDetails',
                                :TRANSACTIONID => transaction_id
                              }.merge!(common_params))
    end
  end
end