class ContributionDecorator < Draper::Decorator
  decorates :contribution
  include Draper::LazyHelpers

  def display_value
    number_to_currency source.value
  end

  def display_confirmed_at
    I18n.l(source.confirmed_at.to_date) if source.confirmed_at
  end

  def display_slip_url
    return source.slip_url if source.slip_url.present?
    "https://www.moip.com.br/Boleto.do?id=#{source.payment_id.gsub('.', '').to_i}"
  end
end

