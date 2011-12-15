class PaypalApi
  class << self
    attr_accessor :username, :password, :signature
    def configure(&block)
      yield self if block_given?
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
      request = HTTParty.get(build_url(transaction_id))
      if request.code.to_i == 200
        {
          :service_tax_amount => find_element_value("FEEAMT", request.body).to_f
        }
      else
        {}
      end
    end

    def build_url(transaction_id)
      params = { :METHOD => 'GetTransactionDetails',
                 :TRANSACTIONID => transaction_id }.merge!(common_params).to_a
      params_url = params.inject([]) do |total, item|
                    total << "#{item[0]}=#{item[1]}"
                  end.join("&")
      "#{endpoint}?#{params_url}"
    end

    def find_element_value(element, body)
      finded = parse_paypal_response(body).find { |obj| obj[0] == element }
      CGI::unescape(finded[1]) if finded && finded[1]
    end

    def parse_paypal_response(body)
      body.split('&').collect do |parsed|
        parsed.split('=')
      end
    end
  end
end