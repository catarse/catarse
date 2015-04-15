class ContributionDetailDecorator < Draper::Decorator
  decorates :contribution_detail
  include Draper::LazyHelpers

  def display_installment_details
    if source.installments > 1
      "#{source.installments} x #{number_to_currency source.installment_value}"
    else
      ""
    end
  end

  def display_payment_details
    if source.credits?
      I18n.t("contribution.payment_details.creditos")
    elsif source.payment_method.present?
      I18n.t("contribution.payment_details.#{source.payment_method.underscore}")
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
    gateway_data = source.try(:gateway_data)
    return gateway_data["boleto_url"] if gateway_data.present?
  end

  def display_status
    state = source.state
    I18n.t("payment.state.#{state}", date: display_date("#{state}_at"))
  end
end

