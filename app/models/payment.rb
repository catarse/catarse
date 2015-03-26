class Payment < ActiveRecord::Base
  include Shared::StateMachineHelpers

  has_and_belongs_to_many :contributions

  validates_presence_of :state, :key, :gateway, :method, :value, :installments, :installment_value
  validate :value_should_be_equal_or_greater_than_pledge

  before_validation do
    self.key ||= SecureRandom.uuid
  end

  def value_should_be_equal_or_greater_than_pledge
    errors.add(:value, I18n.t("activerecord.errors.models.payment.attributes.value.invalid")) if self.contribution && self.value < self.contribution.value
  end

  def contribution
    contributions.first
  end

  state_machine :state, initial: :pending do
    state :pending
    state :paid
    state :pending_refund
    state :refunded
    state :refused
  end
end
