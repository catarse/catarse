# frozen_string_literal: true

class Admin::SubscriptionPaymentsController < Admin::BaseController
  layout 'catarse_bootstrap'

  # batch_chargeback is used as external action in catarse.js
  def batch_chargeback
    authorize Admin, :batch_chargeback?
    collection_for_chargeback.each do |subscription_payment|
        subscription_payment.chargeback
    end

    render json: { subscription_payment_ids: collection_for_chargeback.pluck(:id) }
  end

  def refund
    authorize Admin, :refund_subscription_payment?

    begin
      subscription_payment = SubscriptionPayment.find(refund_payment_params['payment_common_id'])
      subscription_payment.refund

      render json: { success: I18n.t("admin.refund_subscriptions.refund_success") }, status: :created
    rescue => exception
      Raven.capture_exception(exception)
      render json: { errors: [exception.message] }, status: :unprocessable_entity
    end
  end

  protected

  def collection_for_chargeback
    @collection_for_chargeback ||= SubscriptionPayment.where("(gateway_general_data->>'gateway_id')::text in (?) and (gateway_general_data->>'gateway_id')::text is not null", params[:gateway_payment_ids])
  end

  private

  def refund_payment_params
    params.require(:refund_payment).permit(:payment_common_id)
  end
end
