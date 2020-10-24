# frozen_string_literal: true

class ContributionDetailDecorator < Draper::Decorator
  decorates :contribution_detail
  include Draper::LazyHelpers

  def display_installment_details
    if object.installments > 1
      "#{object.installments} x #{number_to_currency object.installment_value}"
    else
      ''
    end
  end

  def display_payment_details
    if object.credits?
      I18n.t('contribution.payment_details.creditos')
    elsif object.payment_method.present?
      I18n.t("contribution.payment_details.#{object.payment_method.underscore}")
    else
      ''
    end
  end

  def display_value
    number_to_currency object.localized.value
  end

  def display_slip_url
    gateway_data = object.try(:gateway_data)
    return gateway_data['boleto_url'] if gateway_data.present?
  end

  def display_status
    state = object.state
    I18n.t("payment.state.#{state}", date: I18n.l(object["#{state}_at".to_sym].to_date))
  end
end
