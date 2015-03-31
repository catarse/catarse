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

  def display_name
    source.name.presence || I18n.t('user.no_name')
  end

  def display_image
    source.uploaded_image.thumb_avatar.url || '/assets/catarse_bootstrap/user.jpg'
  end

  def display_image_html 
    (%{<div class="avatar_wrapper">} +
      h.image_tag(display_image, alt: "User", class: "thumb big u-round") +
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
    number_to_currency source.payments.with_state('paid').sum(:value)
  end
end
