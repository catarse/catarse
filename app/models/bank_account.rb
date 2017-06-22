# frozen_string_literal: true

class BankAccount < ActiveRecord::Base
  BANK_CODE_TABLE = %w[237 001 341 033 104 399 745].freeze
  include CatarsePagarme::BankAccountConcern
  include Shared::BankAccountHelper

  belongs_to :user
  belongs_to :bank

  validates :bank_id, :agency, :account, :account_digit, :account_type, presence: true
  validates :account_type, inclusion: { in: %w[conta_corrente conta_poupanca conta_corrente_conjunta conta_poupanca_conjunta] }

  attr_accessor :input_bank_number
  validate :input_bank_number_validation
  validates :agency, length: { is: 4 }, if: :bank_code_in_validation_table?
  validates :account_digit, length: { is: 1 }, if: :bank_code_in_validation_table?
  validates :agency_digit, length: { is: 1 }, if: ->(ba) {
    %w[237 001].include?(ba.bank_code.to_s)
  }
  validates :account, length: { maximum: 7 }, if: ->(ba) {
    %w[237].include?(ba.bank_code.to_s)
  }
  validates :account, length: { maximum: 8 }, if: ->(ba) {
    %w[001 033].include?(ba.bank_code.to_s)
  }
  validates :account, length: { is: 5 }, if: ->(ba) {
    %w[341].include?(ba.bank_code.to_s)
  }
  validates :account, length: { maximum: 11 }, if: ->(ba) {
    %w[104].include?(ba.bank_code.to_s)
  }
  validates :account, length: { is: 6 }, if: ->(ba) {
    %w[399].include?(ba.bank_code.to_s)
  }
  validates :account, length: { is: 7 }, if: ->(ba) {
    %w[745].include?(ba.bank_code.to_s)
  }

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
