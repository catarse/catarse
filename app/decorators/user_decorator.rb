# coding: utf-8
# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  decorates :user
  include Draper::LazyHelpers

  def contributions_text
    if source.total_contributed_projects == 2
      I18n.t('user.contributions_text.two')
    elsif source.total_contributed_projects > 1
      I18n.t('user.contributions_text.many', total: (source.total_contributed_projects - 1))
    else
      I18n.t('user.contributions_text.one')
    end
  end

  def twitter_link
    "http://twitter.com/#{source.twitter}" unless source.twitter.blank?
  end

  def display_name
    source.public_name.presence || source.name.presence || I18n.t('user.no_name')
  end

  def display_image
    source.uploaded_image.thumb_avatar.url || "#{CatarseSettings[:base_url]}/assets/catarse_bootstrap/user.jpg"
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
    number_to_currency source.credits
  end

  # Return the total amount from pending refund payments
  def display_pending_refund_payments_amount
    number_to_currency(
      source.pending_refund_payments.sum(&:value), # + source.credits, for legacy
      precision: 2
    )
  end

  # Return array with name of projects that user
  # have pending refund payments
  def display_pending_refund_payments_projects_name
    source.pending_refund_payments_projects.map(&:name).uniq
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
    "#{source.name} / CPF: #{source.cpf}" if source.bank_account.present?
  end

  def display_total_of_contributions
    number_to_currency source.payments.with_state('paid').sum(:value)
  end

  def display_bank_account
    bank_account = source.bank_account
    if bank_account.present?
      "#{bank_account.bank.code} - #{bank_account.bank.name} /
      AG. #{bank_account.agency}-#{bank_account.agency_digit} /
      CC. #{bank_account.account}-#{bank_account.account_digit} (#{bank_account.account_type}) /
    #{source.account_type}"
    else
      I18n.t('not_filled')
    end
  end

  def display_bank_account_owner
    "#{source.name} / CPF: #{source.cpf}"
  end

  def display_address
    "#{source.address_street}, #{source.address_number} - #{source.address_complement}, #{source.address_neighbourhood}, #{source.address_city}, #{source.address_state} #{source.address_zip_code}"
  end

  def entity_type
    case source.account_type
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
