module PaymentHistory
  class Moip

    attr_accessor :params, :response_code, :backer

    def initialize(post_params)
      @params = post_params
    end

    def process_request!
      begin
        @backer = find_backer
        if @backer.moip_value == @params[:valor].to_s
          build_log

          unless @backer.confirmed
            payment_detail = (@backer.payment_detail||@backer.build_payment_detail)
            payment_detail.update_from_service
          end

          case @params[:status_pagamento].to_i
          when TransactionStatus::AUTHORIZED
            @backer.confirm! if not @backer.confirmed
          when TransactionStatus::WRITTEN_BACK
            unless @backer.refunded
              @backer.update_attributes({refunded: true, requested_refund: true})
            end
          when TransactionStatus::REFUNDED
            unless @backer.refunded
              @backer.update_attributes({refunded: true, requested_refund: true})
            end
          end

        else
          @response_code = ResponseCode::NOT_PROCESSED
        end

      rescue
        @response_code = ResponseCode::NOT_PROCESSED
      end
      self
    end

    def build_log
      @backer.payment_logs.create!({
        :moip_id => @params[:cod_moip],
        :amount => @params[:valor],
        :payment_status => @params[:status_pagamento],
        :payment_type => @params[:tipo_pagamento],
        :payment_method => @params[:forma_pagamento],
        :consumer_email => @params[:email_consumidor]
      })
      @response_code = ResponseCode::SUCCESS
    end

    def find_backer
      @backer = Backer.find_by_key! @params[:id_transacao]
    end

    class ResponseCode < EnumerateIt::Base
      associate_values(
        :not_processed => 422,
        :success => 200
      )
    end

    #MoIP API table:
    class PaymentMethods < EnumerateIt::Base
      associate_values(
        :DebitoBancario         => 1,
        :FinanciamentoBancario  => 2,
        :BoletoBancario         => 3,
        :CartaoDeCredito        => 4,
        :CartaoDeDebito         => 5,
        :CarteiraMoIP           => 6,
        :NaoDefinida            => 7
      )
    end

    class TransactionStatus < EnumerateIt::Base
      associate_values(
        :authorized =>      1,
        :started =>         2,
        :printed_boleto =>  3,
        :finished =>        4,
        :canceled =>        5,
        :process =>         6,
        :written_back =>    7,
        :refunded => 9
      )
    end
  end
end
