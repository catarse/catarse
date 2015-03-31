class ContributionDecorator < Draper::Decorator
  decorates :contribution
  include Draper::LazyHelpers

  def display_installment_details
    if source.installments > 1
      "#{contribution.installments} x #{number_to_currency contribution.installment_value}"
    else
      ""
    end
  end

  def display_payment_details
    if source.credits?
      I18n.t("contribution.payment_details.creditos")
    elsif source.payment_choice.present?
      I18n.t("contribution.payment_details.#{source.payment_choice.underscore}")
    else
      ""
    end
  end

  def display_value
    number_to_currency source.localized.value
  end

  def display_date date_field
    I18n.l(source[date_field.to_sym].to_date) if source[date_field.to_sym]
  end

  def display_slip_url
    gateway_data = source.payments.last.try(:gateway_data)
    return gateway_data["boleto_url"] if gateway_data.present?
  end
end

