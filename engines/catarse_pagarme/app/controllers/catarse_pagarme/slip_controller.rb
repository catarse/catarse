# frozen_string_literal: true

require 'weekdays'

module CatarsePagarme
  class SlipController < CatarsePagarme::ApplicationController

    def create
      transaction = SlipTransaction.new(slip_attributes, payment).charge!

      render json: { boleto_url: transaction.boleto_url, payment_status: transaction.status, gateway_data: payment.gateway_data }
    rescue PagarMe::PagarMeError => e
      raven_capture(e)
      render json: { boleto_url: nil, payment_status: 'failed', message: e.message }
    end

    def update
      payment.generating_second_slip = true
      transaction = SlipTransaction.new(slip_attributes, payment).charge!
      respond_to do |format|
        format.html { redirect_to transaction.boleto_url }
        format.json do
          { boleto_url: transaction.boleto_url }
        end
      end
    end

    def slip_data
      render json: {slip_expiration_date: payment.slip_expiration_date.to_date}
    end

    protected

    def slip_attributes
      {
        payment_method: 'boleto',
        boleto_rules: ['strict_expiration_date'],
        boleto_expiration_date: payment.slip_expiration_date,
        amount: delegator.value_for_transaction,
        postback_url: ipn_pagarme_index_url(
          host: CatarsePagarme.configuration.host,
          subdomain: CatarsePagarme.configuration.subdomain,
          protocol: CatarsePagarme.configuration.protocol
        ),
        customer: {
          email: payment.user.email,
          name: payment.user.name,
          type: payment.user.account_type == 'pf' ? 'individual' : 'corporation',
          documents: [{
            type:  payment.user.account_type == 'pf' ? 'cpf' : 'cnpj',
            number: document_number
          }],
        },
        metadata: metadata_attributes.merge({ second_slip: payment.generating_second_slip.to_s })
      }
    end

    def document_number
      international? ? '00000000000' : contribution.user.cpf.gsub(/[-.\/_\s]/,'')
    end

    def international?
      contribution.international?
    end
  end
end
