# frozen_string_literal: true

require "pagarme"

module CatarsePagarme
  class ApplicationController < ActionController::Base

    before_action :authenticate_user!
    before_action :configure_pagarme
    helper_method :payment
    layout :false

    protected
    def raven_capture exception
      ::Raven.user_context(
        {
          contribution_id: payment.contribution_id,
          user_id: contribution.user_id,
          payment_key: payment.key,
          project_id: contribution.project_id,
          payment_method: payment.payment_method
        }
      )
      ::Raven.capture_exception(exception, level: 'fatal')
      ::Raven.user_context({})
    end

    def metadata_attributes
      {
        key: payment.generate_key,
        contribution_id: payment.contribution.id.to_s,
        project_id: payment.project.id.to_s,
        project_name: payment.project.name,
        permalink: payment.project.permalink,
        project_online: payment.project.online_at,
        project_expires: payment.project.expires_at,
        user_total_contributions: payment.user.contributions.was_confirmed.count,
        user_id: payment.user.id,
        common_user_id: payment.user.common_id.to_s,
        user_name: payment.user.name,
        user_email: payment.user.email
      }
    end

    def configure_pagarme
      PagarMe.api_key = CatarsePagarme.configuration.api_key
    end

    def authenticate_user!
      unless defined?(current_user) && current_user
        raise Exception.new('invalid user')
      end

      if current_user != contribution.user
        raise Exception.new('invalid user') unless current_user.admin?
      end
    end

    def permited_attrs(attributes)
      attrs = ActionController::Parameters.new(attributes)
      attrs.permit([
        slip_payment: [:payment_method, :amount, :postback_url,
                       customer: [:name, :email]
        ],
        user: [
          bank_account_attributes: [
            :name, :account, :account_digit, :agency,
            :agency_digit, :owner_name, :owner_document
          ]
        ]
      ])
    end

    def contribution
      @contribution ||= PaymentEngines.find_contribution(params[:id])
    end

    def payment
      attributes = {contribution: contribution, value: contribution.value}
      @payment ||= PaymentEngines.new_payment(attributes)
    end

    def delegator
      payment.pagarme_delegator
    end
  end
end
