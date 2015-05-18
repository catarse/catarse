class ProjectAccountDecorator < Draper::Decorator
  decorates :project_account
  include Draper::LazyHelpers

  def display_bank_account
    if source.bank.present?
      "#{source.bank.code} - #{source.bank.name} /
      AG. #{source.agency}-#{source.agency_digit} /
      CC. #{source.account}-#{source.account_digit} /
      #{source.account_type}"
    else
      I18n.t('not_filled')
    end
  end

  def display_bank_account_owner
    if source.bank.present?
      "#{source.owner_name} / CPF: #{source.owner_document}"
    end
  end

  def display_address
    "#{source.address_street}, #{source.address_number} - #{source.address_complement}, #{source.address_neighbourhood}, #{source.address_city}, #{source.address_state} #{source.address_zip_code}"
  end

end
