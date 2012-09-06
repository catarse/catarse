class UserDecorator < Draper::Base
  decorates :user
  include Draper::LazyHelpers

  def display_provider
    case provider
    when 'devise' then "Login #{email}"
    when 'google' then I18n.t('user.google_account')
    else provider
    end
  end

  def display_name
    name || nickname || I18n.t('user.no_name')
  end

  def display_image
    image_url.to_s || gravatar_url || '/assets/user.png'
  end

  def short_name
    truncate display_name, :length => 26
  end

  def medium_name
    truncate display_name, :length => 42
  end

  def display_credits
    number_to_currency credits, :unit => 'R$', :precision => 0, :delimiter => '.'
  end

  def display_total_of_backs
    number_to_currency backs.confirmed.sum(:value), :unit => 'R$', :precision => 0, :delimiter => '.'
  end
end
