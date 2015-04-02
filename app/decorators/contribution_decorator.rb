class ContributionDecorator < Draper::Decorator
  decorates :contribution
  include Draper::LazyHelpers

  def display_installment_details
    if last_payment.installments > 1
      "#{last_payment.installments} x #{number_to_currency last_payment.installment_value}"
    else
      ""
    end
  end

  def display_payment_details
    if last_payment.credits?
      I18n.t("contribution.payment_details.creditos")
    elsif last_payment.payment_method.present?
      I18n.t("contribution.payment_details.#{last_payment.payment_method.underscore}")
    else
      ""
    end
  end

  def display_value
    number_to_currency source.localized.value
  end

  def display_date date_field
    I18n.l(last_payment[date_field.to_sym].to_date) if last_payment[date_field.to_sym]
  end

  def display_slip_url
    gateway_data = last_payment.try(:gateway_data)
    return gateway_data["boleto_url"] if gateway_data.present?
  end

  def display_status
    state = last_payment.state
    I18n.t("payment.state.#{state}", date: display_date("#{state}_at"))
  end

  private
  def last_payment
    source.payments.last
  end
end

