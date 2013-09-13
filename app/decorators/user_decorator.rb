class UserDecorator < Draper::Decorator
  decorates :user
  include Draper::LazyHelpers

  def display_name
    source.name || source.full_name || I18n.t('user.no_name')
  end

  def display_image
    source.uploaded_image.thumb_avatar.url || source.image_url || source.gravatar_url || '/assets/user.png'
  end

  def display_image_html options={width: 119, height: 121}
    (%{<div class="avatar_wrapper" style="width: #{options[:width]}px; height: #{options[:height]}px">} +
      h.image_tag(display_image, alt: "User", style: "width: #{options[:width]}px; height: auto") +
      %{</div>}).html_safe
  end

  def short_name
    truncate display_name, length: 20
  end

  def medium_name
    truncate display_name, length: 42
  end

  def display_credits
    number_to_currency source.credits
  end

  def display_total_of_backs
    number_to_currency source.backs.with_state('confirmed').sum(:value)
  end
end
