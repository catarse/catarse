class ContributionDecorator < Draper::Decorator
  decorates :contribution
  include Draper::LazyHelpers

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

