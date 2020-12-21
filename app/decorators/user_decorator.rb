# coding: utf-8
# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  decorates :user
  include Draper::LazyHelpers

  def contributions_text
    if object.total_contributed_projects == 2
      I18n.t('user.contributions_text.two')
    elsif object.total_contributed_projects > 1
      I18n.t('user.contributions_text.many', total: (object.total_contributed_projects - 1))
    else
      I18n.t('user.contributions_text.one')
    end
  end

  def twitter_link
    "http://twitter.com/#{object.twitter}" unless object.twitter.blank?
  end

  def display_name
    object.public_name.presence || object.name.presence || I18n.t('user.no_name')
  end

  def display_image
    object.uploaded_image.thumb_avatar.url || "#{CatarseSettings[:base_url]}/assets/catarse_bootstrap/user.jpg"
  end

  def display_image_html
    (%(<div class="avatar_wrapper">) +
      h.image_tag(display_image, alt: 'User', class: 'thumb big u-round') +
      %(</div>)).html_safe
  end

  def short_name
    truncate display_name, length: 20
  end

  def medium_name
    truncate display_name, length: 42
  end

  def display_credits
    number_to_currency object.credits
  end

  # Return the total amount from pending refund payments
  def display_pending_refund_payments_amount
    number_to_currency(
      object.pending_refund_payments.sum(&:value), # + object.credits, for legacy
      precision: 2
    )
  end

  # Return array with name of projects that user
  # have pending refund payments
  def display_pending_refund_payments_projects_name
    object.pending_refund_payments_projects.map(&:name).uniq
  end

  def display_bank_account
    if object.bank_account.present?
      "#{object.bank_account.bank.code} - #{object.bank_account.bank.name} /
      AG. #{object.bank_account.agency}-#{object.bank_account.agency_digit} /
      CC. #{object.bank_account.account}-#{object.bank_account.account_digit}"
    else
      I18n.t('not_filled')
    end
  end

  def display_bank_account_owner
    "#{object.name} / CPF: #{object.cpf}" if object.bank_account.present?
  end

  def display_total_of_contributions
    number_to_currency object.payments.with_state('paid').sum(:value)
  end

  def display_bank_account
    bank_account = object.bank_account
    if bank_account.present?
      "#{bank_account.bank.code} - #{bank_account.bank.name} /
      AG. #{bank_account.agency}-#{bank_account.agency_digit} /
      CC. #{bank_account.account}-#{bank_account.account_digit} (#{bank_account.account_type}) /
    #{object.account_type}"
    else
      I18n.t('not_filled')
    end
  end

  def display_bank_account_owner
    "#{object.name} / CPF: #{object.cpf}"
  end

  def display_address
    "#{object.address_street}, #{object.address_number} - #{object.address_complement}, #{object.address_neighbourhood}, #{object.address_city}, #{object.address_state} #{object.address_zip_code}"
  end

  def entity_type
    case object.account_type
    when 'pf'
      'Pessoa Física'
    when 'pj'
      'Pessoa Jurídica'
    when 'mei'
      'Pessoa Jurídica - MEI'
    else
      'Pessoa Física'
    end
  end
end
