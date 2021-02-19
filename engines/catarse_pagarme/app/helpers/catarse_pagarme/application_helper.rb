# frozen_string_literal: true

module CatarsePagarme
  module ApplicationHelper

    def installments_for_select(payment)
      installments = payment.pagarme_delegator.get_installments['installments']
      project = payment.project

      collection = installments.map do |installment|
        installment_number = installment[0].to_i
        if installment_number <= (project.try(:total_installments) || CatarsePagarme.configuration.max_installments.to_i)
          amount = installment[1]['installment_amount'] / 100.0

          optional_text = nil
          if installment_number != 1
            optional_text = I18n.t('projects.contributions.edit.installment_with_tax')
          end

          ["#{format_instalment_text(installment_number, amount)} #{optional_text}", installment_number]
        end
      end

      collection.compact
    end

    def format_instalment_text(number, amount)
      [number, number_to_currency(amount, precision: 2)].join("x ")
    end

  end
end
