# frozen_string_literal: true
require 'net/http'

class BankAccount < ActiveRecord::Base
  BANK_CODE_TABLE = %w[237 001 341 033 104 399 745].freeze
  include CatarsePagarme::BankAccountConcern
  include Shared::BankAccountHelper

  belongs_to :user
  belongs_to :bank

  validates :bank_id, :account_digit, :account_type, presence: true
  validates :account_type, inclusion: { in: %w[conta_corrente conta_poupanca conta_corrente_conjunta conta_poupanca_conjunta] }

  attr_accessor :input_bank_number
  validate :input_bank_number_validation
  validates :agency_digit, length: { is: 1 }, if: ->(ba) {
    %w[237 001].include?(ba.bank_code.to_s)
  }

  validate :agency, :agency_validation
  validate :account, :account_validation
  validate :account_digit, :account_digit_validation
  validate :bank_account_valid

  def agency_validation
    
    errors.delete :agency

    if agency == nil || agency.length == 0
      errors.add(:agency, :blank) 
      return false
    end

    if agency.length != 4
      errors.add(:agency, :format) 
      return false
    end

    if !agency.match? /\d{4}/
      errors.add(:agency, :invalid)
      return false
    end

    bank_code_in_validation_table?
  end

  def account_validation

    # setup locale custom access
    account_locale = 'activerecord.errors.models.bank_account.attributes.account'
    account_equal_locale = I18n.t("#{account_locale}.equal")
    account_maximum_locale = I18n.t("#{account_locale}.maximum")
    account_invalid_locale = I18n.t("#{account_locale}.invalid")

    errors.delete :account

    if account == nil || account.length == 0
      errors.add(:account, :blank)
      return false
    end

    if account.match? /\D+/
      errors.add(:account, :format)
      return false
    end

    if %w[237].include?(bank_code.to_s) && account.length > 7
      account_error = (account_invalid_locale + account_maximum_locale) % [7]
      errors.add(:account, account_error)
      return false
    end 

    if %w[001 033].include?(bank_code.to_s) && account.length > 8
      account_error = (account_invalid_locale + account_maximum_locale) % [8]
      errors.add(:account, account_error)
      return false
    end 

    if %w[341].include?(bank_code.to_s) && account.length != 5
      account_error = (account_invalid_locale + account_equal_locale) % [5]
      errors.add(:account, account_error)
      return false
    end 

    if %w[104].include?(bank_code.to_s) && account.length > 11
      account_error = (account_invalid_locale + account_maximum_locale) % [11]
      errors.add(:account, account_error)
      return false
    end 

    if %w[399].include?(bank_code.to_s) && account.length != 6
      account_error = (account_invalid_locale + account_equal_locale) % [6]
      errors.add(:account, account_error)
      return false
    end 

    if %w[745].include?(bank_code.to_s) && account.length != 7
      account_error = (account_invalid_locale + account_equal_locale) % [7]
      errors.add(:account, account_error)
      return false
    end 
    
    return true
  end

  def account_digit_validation

    errors.delete :account_digit

    if account_digit == nil || account_digit.length == 0
      errors.add(:account_digit, :blank)
      return false
    end

    if account_digit.length != 1
      errors.add(:account_digit, :format)
      return false
    end

    bank_code_in_validation_table?
  end

  def bank_account_valid
    validation = Transfeera::BankAccountValidator.validate(self)
    if !validation[:valid]
      validation[:errors].each do |error|
        errors.add(error[:field], error[:message])
      end
    end
  end

  # before validate bank account we inject the founded
  # bank account via input_bank_number
  before_validation :load_bank_from_input_bank_number

  accepts_nested_attributes_for :user, allow_destroy: false

  def bank_code
    bank.try(:code)
  end

  def complete_agency_string
    return agency unless agency_digit.present?
    "#{agency} - #{agency_digit}"
  end

  def bank_code_in_validation_table?
    bank_code = bank.try(:code)
    BANK_CODE_TABLE.include?(bank_code.to_s)
  end

  def complete_account_string
    "#{account} - #{account_digit}"
  end

  def account_type_list
    I18n.t('projects.successful_onboard.confirm_account.person.bank.account_type').to_a.map do |memo|
      [memo[1], memo[0].to_s]
    end
  end

  def to_hash_with_bank
    self.attributes.merge(bank_code: bank_code, bank_name: bank.name)
  end
end