module CatarsePagarme
  class NotificationsController < CatarsePagarme::ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    def create
      if payment
        payment.payment_notifications.create(contribution: payment.contribution, extra_data: params.to_json)

        if valid_postback?
          delegator.change_status_by_transaction(params[:current_status])
          delegator.update_transaction

          render(body: nil, status: 200) and return
        end
      end

      render json: { error: 'invalid postback' }, status: 400
    end

    protected

    def payment
      @payment ||=  PaymentEngines.find_payment({ gateway_id: params[:id], gateway: 'Pagarme' })
    end

    def valid_postback?
      raw_post  = request.raw_post
      signature = request.headers['HTTP_X_HUB_SIGNATURE']
      PagarMe::Postback.valid_request_signature?(raw_post, signature)
    end
  end
end
