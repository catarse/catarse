# frozen_string_literal: true

# This controller is only a wrapper to trigger chargeback 
# on common wrapper
class Admin::SubscriptionPaymentsController < Admin::BaseController
  layout 'catarse_bootstrap'

  # batch_chargeback is used as external action in catarse.js
  def batch_chargeback
    collection.each do |subscription_payment|
      susbcription_payment.chargeback
    end

    render json: { subscription_payment_ids: collection.pluck(:id) }
  end

  protected

  def collection
    SubscriptionPayment.where(id: params[:subscription_payment_ids])
  end
end
