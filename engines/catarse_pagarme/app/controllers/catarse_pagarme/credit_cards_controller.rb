# coding: utf-8
module CatarsePagarme
  class CreditCardsController < CatarsePagarme::ApplicationController
    MAX_SOFT_DESCRIPTOR_LENGTH = 13

    def create
      transaction = CreditCardTransaction.new(credit_card_attributes, payment).process!

      render json: { payment_status: transaction.status }
    rescue PagarMe::PagarMeError, PagarMe::ValidationError => e
      # should ignore refused payments
      if payment.state != 'refused'
        raven_capture(e)
      end
      payment.destroy if payment.persisted? && !payment.gateway_id.present?

      render json: { payment_status: 'failed', message: e.message }
    rescue => e
      raven_capture(e)

      render json: { payment_status: 'failed', message: e.message }
    end

    def get_installment_json
      render json: installments_for_json.to_json
    end

    def get_encryption_key_json
      render json: { key: CatarsePagarme.configuration.ecr_key }
    end

    protected

    def credit_card_attributes
      contribution.reload
      hash = {
        payment_method: 'credit_card',
        amount: delegator.value_with_installment_tax(get_installment),
        postback_url: ipn_pagarme_index_url(
          host: CatarsePagarme.configuration.host,
          subdomain: CatarsePagarme.configuration.subdomain,
          protocol: CatarsePagarme.configuration.protocol
        ),
        soft_descriptor: payment.project.permalink.gsub(/[\W\_]/, ' ')[0, MAX_SOFT_DESCRIPTOR_LENGTH],
        installments: get_installment,
        customer: {
          id: contribution.user.id,
          email: contribution.user.email,
          name: contribution.user.name,
          document_number: document_number,
          address: {
            street: contribution.address_street,
            neighborhood: neighborhood,
            zipcode: zip_code,
            street_number: address_number,
            complementary: contribution.address_complement,
            city: contribution.address_city,
            state: contribution.address_state,
            country: contribution.country.try(:name)
          },
          phone: {
            ddd: phone_matches.try(:[], 1),
            number: phone_matches.try(:[], 2)
          }
        },
        metadata: metadata_attributes,
        antifraud_metadata: af_metadata
      }

      if params[:card_hash].present?
        hash[:card_hash] = params[:card_hash]
      else
        hash[:card_id] = params[:card_id]
      end

      hash[:save_card] = (params[:save_card] == 'true')

      hash
    end

    def address_number
      international? ? 100 : contribution.address_number
    end

    def document_number
      contribution.user.cpf.try(:gsub, /[-.\/_\s]/, '')
    end

    def phone_matches
      international? ? ['', '33', '33335555'] : contribution.phone_number.gsub(/[\s,-]/, '').match(/\((.*)\)(\d+)/)
    end

    def zip_code
      international? ? '00000000' : contribution.address_zip_code.gsub(/[-.]/, '')
    end

    def neighborhood
      international? ? 'international' : contribution.address_neighbourhood
    end

    def international?
      contribution.international?
    end

    def get_installment
      if payment.value.to_f < CatarsePagarme.configuration.minimum_value_for_installment.to_f
        1
      elsif params[:payment_card_installments].to_i > 0
        params[:payment_card_installments].to_i
      else
        1
      end
    end

    def installments_for_json
      if contribution.value.to_f >= CatarsePagarme.configuration.minimum_value_for_installment.to_f
        project = payment.project
        installments = payment.pagarme_delegator.get_installments['installments']
        collection = installments.map do |installment|
          installment_number = installment[0].to_i

          if installment_number <= (project.try(:total_installments) || CatarsePagarme.configuration.max_installments.to_i)
            amount = installment[1]['installment_amount'] / 100.0

            { amount: amount, number: installment_number, total_amount: installment[1]['amount'] / 100.0, free_installment: (project.free_installments >= installment_number.to_i) }
          end
        end
      else
        collection = [{ amount: payment.value, number: 1, total_amount: payment.value }]
      end
      collection.compact
    end

    def address_hash
      {
        country_code: contribution.country.try(:code),
        state: contribution.address_state,
        city: contribution.address_city,
        zipcode: contribution.address_zip_code.try(:gsub, /[-.\/_\s]/, ''),
        neighborhood: contribution.address_neighbourhood,
        street: contribution.address_street,
        street_number: contribution.address_number,
        complementary: contribution.address_complement,
        latitude: '',
        longitude: ''
      }
    end

    def af_metadata
      project = contribution.project
      user = contribution.user

      {
        session_id: contribution.id.to_s,
        ip: user.current_sign_in_ip,
        platform: "web",
        register: {
          id: contribution.user_id.to_s,
          email: user.email,
          registered_at: user.created_at.to_s,
          login_source: "registered",
          company_group: "",
          classification_code: ""
        },
        billing: {
          customer: {
            name: "",
            document_number: contribution.card_owner_document.try(:gsub, /[-.\/_\s]/, ''),
            born_at: "",
            gender: ""
          },
          address: address_hash,
          phone_numbers: [
            {
              ddi: "",
              ddd: phone_matches.try(:[], 1),
              number: phone_matches.try(:[], 2)
            }]
        },
        buyer: {
          customer: {
            name: user.name,
            document_number: user.cpf.try(:gsub, /[-.\/_\s]/, ''),
            born_at: "",
            gender: ""
          },
          address: address_hash,
          phone_numbers: [
            {
              ddi: "",
              ddd: phone_matches.try(:[], 1),
              number: phone_matches.try(:[], 2)
            }]
        },
        shipping: {
          customer: {
            name: contribution.user.name,
            document_number: contribution.user.cpf.try(:gsub, /[-.\/_\s]/, ''),
            born_at: "",
            gender: ""
          },
          address: address_hash,
          phone_numbers: [
            {
              ddi: "00",
              ddd: phone_matches.try(:[], 1),
              number: phone_matches.try(:[], 2)
            }],
          shipping_method: "",
          fee: 0,
          favorite: false
        },
        shopping_cart: [
          {
            name: "#{contribution.value.to_s} - #{contribution.project.name}",
            type: "contribution",
            quantity: "1",
            unit_price: (contribution.value * 100).to_i.to_s,
            totalAdditions: 0,
            totalDiscounts: 0,
            event_id: contribution.project_id.to_s,
            ticket_type_id: "0",
            ticket_owner_name: user.name,
            ticket_owner_document_number: user.cpf.try(:gsub, /[-.\/_\s]/, '')
          }],
        discounts: [
          {
            type: "other",
            code: "",
            amount: 0
          }],
        other_fees: [
          {
            type: "",
            amount: 0
          }],
        events: [
          {
            id: contribution.project_id.to_s,
            name: contribution.project.name,
            type: contribution.project.mode == 'flex' ? 'flex' : 'full',
            date: contribution.project.created_at.to_s,
            venue_name: project.user.name,
            address: {
              country: "Brasil",
              state: project.user.address_state,
              city: project.user.address_city,
              zipcode: project.user.address_zip_code,
              neighborhood: project.user.address_neighbourhood,
              street: project.user.address_street,
              street_number: project.user.address_number,
              complementary: project.user.address_complement,
              latitude: 0.0,
              longitude: 0.0
            },
            ticket_types: [
              {
                id: contribution.id,
                name: "",
                type: "",
                batch: "",
                price: (contribution.value * 100).to_i.to_s,
                available_number: 0,
                total_number: 0,
                identity_verified: "",
                assigned_seats:  ""
              }]
          }]
      }

    end

  end
end
