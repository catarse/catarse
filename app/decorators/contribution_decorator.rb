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
    return source.slip_url if source.slip_url.present?
    "https://www.moip.com.br/Boleto.do?id=#{source.payment_id.gsub('.', '').to_i}"
  end
end

