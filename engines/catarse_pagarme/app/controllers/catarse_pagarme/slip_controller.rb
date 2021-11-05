# frozen_string_literal: true

require 'weekdays'

module CatarsePagarme
  class SlipController < CatarsePagarme::ApplicationController

    def create
      transaction = SlipTransaction.new(slip_attributes, payment).charge!

      render json: { boleto_url: transaction.boleto_url, payment_status: transaction.status, gateway_data: payment.gateway_data }
    rescue PagarMe::PagarMeError => e
      sentry_capture(e)
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
      attributes = {
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
          external_id: payment.user.id.to_s,
          email: payment.user.email,
          name: payment.user.name,
          type: payment.user.account_type == 'pf' ? 'individual' : 'corporation',
          country: contribution.country.try(:code).downcase || 'br',
          documents: [{
            type:  payment.user.account_type == 'pf' ? 'cpf' : 'cnpj',
            number: document_number
          }],
          phone_numbers: [
            '+55085999999999'
          ]
        },
        billing: {
          name: payment.user.name,
          address: {
            street: contribution.address_street,
            neighborhood: neighborhood,
            zipcode: zip_code,
            street_number: address_number,
            city: contribution.address_city,
            state: contribution.address_state.downcase,
            country: contribution.country.try(:code).downcase
          }
        },
        metadata: metadata_attributes.merge({ second_slip: payment.generating_second_slip.to_s })
      }

      if contribution.address_complement.present?
        attributes[:billing][:address].merge(complementary: contribution.address_complement)
      end

      attributes
    end

    def address_number
      international? ? 100 : contribution.address_number
    end

    def document_number
      international? ? '00000000000' : contribution.user.cpf.gsub(/[-.\/_\s]/,'')
    end

    def neighborhood
      international? ? 'international' : contribution.address_neighbourhood
    end

    def international?
      contribution.international?
    end

    def zip_code
      international? ? '00000000' : contribution.address_zip_code.gsub(/[-.]/, '')
    end
  end
end
