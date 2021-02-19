# frozen_string_literal: true

class Payment < ActiveRecord::Base
  has_many :payment_notifications
  has_many :payment_transfers
  belongs_to :contribution
  delegate :user, :project, to: :contribution

  validates_presence_of :state, :key, :gateway, :payment_method, :value, :installments
  validate :value_should_be_equal_or_greater_than_pledge

  attr_accessor :generating_second_slip

  before_validation do
    generate_key
    self.value ||= self.contribution.try(:value)
    self.state ||= 'pending' # mock initial state for here we do not include the stat machine
  end

  def slip_expiration_date
    2.weekdays_from_now
  end

  def generate_key
    self.key ||= SecureRandom.uuid
  end

  def value_should_be_equal_or_greater_than_pledge
    errors.add(:value, I18n.t("activerecord.errors.models.payment.attributes.value.invalid")) if self.contribution && self.value < self.contribution.value
  end

  def notification_template_for_failed_project
    if slip_payment?
      :contribution_project_unsuccessful_slip
    else
      :contribution_project_unsuccessful_credit_card
    end
  end

  def invalid_refund
    true
  end

  def pending?
    state == 'pending'
  end

  def refunded?
    true
  end

  def paid?
    true
  end

  def refused?
    true
  end

  def refuse
  end

  def pay
  end

  def refund
  end

  def credits?
    self.gateway == 'Credits'
  end

  def slip_payment?
    self.payment_method == 'BoletoBancario'
  end
end
