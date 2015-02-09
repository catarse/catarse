class UserDecorator < Draper::Decorator
  decorates :user
  include Draper::LazyHelpers

  def contributions_text
    if source.total_contributed_projects == 2
      I18n.t('user.contributions_text.two')
    elsif source.total_contributed_projects > 1
      I18n.t('user.contributions_text.many', total: (source.total_contributed_projects-1))
    else
      I18n.t('user.contributions_text.one')
    end
  end

  def twitter_link
    "http://twitter.com/#{source.twitter}" unless source.twitter.blank?
  end

  def gravatar_url
    return unless source.email
    "https://gravatar.com/avatar/#{Digest::MD5.new.update(source.email)}.jpg?default=#{CatarseSettings[:base_url]}/assets/catarse_bootstrap/user.jpg"
  end

  def display_name
    source.name.presence || source.full_name.presence || I18n.t('user.no_name')
  end

  def display_image
    source.personal_image || '/user.png'
  end

  def display_image_html options={width: 119, height: 121}
    (%{<div class="avatar_wrapper" style="width: #{options[:width]}px; height: #{options[:height]}px">} +
      h.image_tag(display_image, alt: "User", style: "width: #{options[:width]}px; height: auto", class: "#{options[:image_class]}") +
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

  def display_bank_account
    if source.bank_account.present?
      "#{source.bank_account.bank.code} - #{source.bank_account.bank.name} /
      AG. #{source.bank_account.agency}-#{source.bank_account.agency_digit} /
      CC. #{source.bank_account.account}-#{source.bank_account.account_digit}"
    else
      I18n.t('not_filled')
    end
  end

  def display_bank_account_owner
    if source.bank_account.present?
      "#{source.bank_account.owner_name} / CPF: #{source.bank_account.owner_document}"
    end
  end

  def display_total_of_contributions
    number_to_currency source.contributions.with_state('confirmed').sum(:value)
  end
end
