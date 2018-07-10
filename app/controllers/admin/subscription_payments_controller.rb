# frozen_string_literal: true

# This controller is only a wrapper to trigger chargeback 
# on common wrapper
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

  protected

  def collection_for_chargeback
    @collection_for_chargeback ||= SubscriptionPayment.where("(gateway_general_data->>'gateway_id')::text in (?) and (gateway_general_data->>'gateway_id')::text is not null", params[:gateway_payment_ids])
  end
end
