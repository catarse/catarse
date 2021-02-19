# frozen_string_literal: true

module CatarsePagarme
  class CreditCardTransaction < TransactionBase
    def process!
      authorize!
      if self.transaction.status == 'authorized'
        if was_credit_card_used_before?
          self.transaction.capture
        else
          antifraud_outcome = process_antifraud

          self.payment.create_antifraud_analysis!(cost: CatarsePagarme.configuration.antifraud_tax)

          if antifraud_outcome.recommendation == :APPROVE
            self.transaction.capture
          elsif antifraud_outcome.recommendation == :DECLINE
            self.transaction.refund
          elsif antifraud_outcome.recommendation == :REVIEW
            self.payment.try(:notify_about_pending_review)
          end
        end
      end

      change_payment_state

      self.transaction
    end

    def authorize!
      save_card = self.attributes.delete(:save_card)

      self.transaction = PagarMe::Transaction.new(
        {
          amount: self.attributes[:amount],
          capture: false,
          async: false,
          postback_url: self.attributes[:postback_url],
          installments: self.attributes[:installments],
          soft_descriptor: self.attributes[:soft_descriptor],
          metadata: self.attributes[:metadata]
        }.merge(credit_card_identifier)
      )

      unless payment.update(gateway: 'Pagarme', payment_method: payment_method)
        raise ::PagarMe::PagarMeError.new(payment.errors.messages.values.flatten.to_sentence)
      end

      self.transaction.charge

      change_payment_state

      if self.transaction.status == 'refused'
        antifraud_wrapper.send(analyze: false)
        raise ::PagarMe::PagarMeError.new(I18n.t('projects.contributions.edit.transaction_error'))
      end

      save_user_credit_card if save_card
    end

    def was_credit_card_used_before?
      PaymentEngines.was_credit_card_used_before?(self.transaction.card.id, self.attributes.dig(:customer, :id))
    end

    def process_antifraud
      begin
        antifraud_wrapper.send(analyze: true)
      rescue RuntimeError => e
        ::Raven.capture_exception(e, level: 'fatal')
        OpenStruct.new(recommendation: :DECLINE)
      end
    end

    def antifraud_wrapper
      @antifraud_wrapper ||= AntifraudOrderWrapper.new(self.attributes, self.transaction)
    end

    def credit_card_identifier
      if self.attributes[:card_hash].present?
        { card_hash: self.attributes[:card_hash] }
      else
        { card_id: self.attributes[:card_id] }
      end
    end

    def save_user_credit_card
      card = self.transaction.card

      credit_card = self.user.credit_cards.find_or_initialize_by(card_key: card.id)
      credit_card.last_digits = card.last_digits
      credit_card.card_brand = card.brand

      credit_card.save!
    end

  end
end
