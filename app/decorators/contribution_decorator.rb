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
    if last_payment.pending?
      "Aguardando confirmação do pagamento"
    elsif last_payment.paid?
      "Confirmado em #{contribution.decorate.display_date(:paid_at)}"
    elsif last_payment.refunded?
      "Reembolsado em #{contribution.decorate.display_date(:refunded_at)}"
    elsif last_payment.pending_refund?
      "Reembolso solicitado em #{contribution.decorate.display_date(:pending_refund_at)}"
    end
  end

  private
  def last_payment
    source.payments.last
  end
end

