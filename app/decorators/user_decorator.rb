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
    uploaded_image.thumb_avatar.url || image_url || gravatar_url || '/assets/user.png'
  end

  def display_image_html options={:width => 119, :height => 121}
    (%{<div class="avatar_wrapper" style="width: #{options[:width]}px; height: #{options[:height]}px">} +
      h.image_tag(uploaded_image.thumb_avatar.url || image_url || gravatar_url || '/assets/user.png', :style => "width: #{options[:width]}px; height: auto") +
      %{</div>}).html_safe
  end

  def short_name
    truncate display_name, :length => 20
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
