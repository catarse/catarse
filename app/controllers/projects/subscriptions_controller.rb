# frozen_string_literal: true

module Projects
  class SubscriptionsController < ApplicationController
    def receipt
      subscription_payment = SubscriptionPayment.find(params[:payment_id])
      authorize subscription_payment

      render 'user_notifier/mailer/subscription_receipt', locals: { subscription_payment: subscription_payment },
        layout: 'layouts/email'
    end
  end
end
