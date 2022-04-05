# frozen_string_literal: true

class SubscriptionPayment < ApplicationRecord
  include Shared::CommonWrapper
  include SubscriptionPayments::RefundHandler

  self.table_name = 'common_schema.catalog_payments'
  self.primary_key = :id

  belongs_to :user, primary_key: :common_id
  belongs_to :project, primary_key: :common_id
  belongs_to :reward, primary_key: :common_id
  belongs_to :subscription
  has_many :balance_transactions, foreign_key: :subscription_payment_uuid
  has_many :subscription_payment_transitions, foreign_key: :catalog_payment_id
  has_many :antifraud_analyses, class_name: 'SubscriptionAntifraudAnalysis', foreign_key: :catalog_payment_id
  validate :banned_user_validation

  def already_in_balance?
    balance_transactions.where(event_name: %i[subscription_fee subscription_payment]).present?
  end

  def chargedback_on_balance?
    balance_transactions.where(event_name: 'subscription_payment_chargedback').exists?
  end

  def gateway_fee
    return 0 unless gateway_general_data.present?
    value = if gateway_general_data['gateway_payment_method'] == 'credit_card'
      gateway_general_data['gateway_cost'].to_i + gateway_general_data['payable_total_fee'].to_i
    else
      gateway_general_data['payable_total_fee'].to_i || gateway_general_data['gateway_cost'].to_i
    end

    value / 100.0
  end

  def amount
    data['amount'].to_f / 100
  end

  def chargeback?
    status == 'chargedback'
  end

  def chargeback
    common_wrapper.chargeback_payment(id)
    BalanceTransaction.insert_subscription_payment_chargedback(id)
  end

  def banned_user_validation
    if self.user.cpf.present?
      document = BlacklistDocument.find_document self.user.cpf
      unless document.nil?
        errors.add(:user, :invalid)
      end
    end
  end
end
