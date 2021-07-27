require 'weekdays'

module CatarsePagarme
  class PixController < CatarsePagarme::ApplicationController

    def create
      transaction = PixTransaction.new(pix_attributes, payment).charge!
      render json: { pix_qr_code: transaction.pix_qr_code, payment_status: transaction.status, gateway_data: payment.gateway_data }
    rescue PagarMe::PagarMeError => e
      sentry_capture(e)
      render json: { pix_qr_code: nil, payment_status: 'failed', message: e.message }
    end

    def update
      payment.generating_second_pix = true
      transaction = PixTransaction.new(pix_attributes, payment).charge!
      redirect_to main_app.project_contribution_path(contribution.project, contribution)
    rescue PagarMe::PagarMeError => e
      sentry_capture(e)
      render json: { pix_qr_code: nil, payment_status: 'failed', message: e.message }
    end

    def pix_expiration_date
      render json: {pix_expiration_date: payment.pix_expiration_date.to_date}
    end

    protected

    def pix_attributes
      {
        payment_method: 'pix',
        amount: delegator.value_for_transaction,
        pix_expiration_date: payment.pix_expiration_date,
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
          country: 'br',
          documents: [{
            type:  payment.user.account_type == 'pf' ? 'cpf' : 'cnpj',
            number: contribution.user.cpf.gsub(/[-.\/_\s]/,'')
          }],
          phone_numbers: [
            '+55085999999999'
          ],
        },
        metadata: metadata_attributes.merge({ second_pix: payment.generating_second_pix.to_s })
      }
    end
  end
end
