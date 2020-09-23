# frozen_string_literal: true

class Payment < ActiveRecord::Base
  include Shared::StateMachineHelpers
  include Payment::PaymentEngineHandler
  include Payment::RequestRefundHandler

  delegate :user, :project, :invalid_refund, :notify_to_backoffice, :is_donation?, :anonymous, to: :contribution

  belongs_to :contribution
  has_one :antifraud_analysis
  has_many :payment_notifications # to keep compatibility with catarse_pagarme
  has_many :payment_transfers
  has_many :gateway_payables

  validates_presence_of :state, :key, :gateway, :payment_method, :value, :installments, :contribution_id
  validate :value_should_be_equal_or_greater_than_pledge
  validate :project_should_be_online, on: :create
  validate :is_unique_on_contribution, on: :create

  attr_accessor :generating_second_slip

  scope :all_boleto_that_should_be_refused, -> {
    where('payments.slip_expires_at + \'3 days\'::interval < current_timestamp and payment_method = \'BoletoBancario\' and state = \'pending\'')
  }

  scope :with_missing_payables, lambda {
    joins('LEFT JOIN gateway_payables gp ON gp.payment_id = payments.id')
      .where("gateway = 'Pagarme' AND state = 'paid' AND payments.gateway_id IS NOT NULL")
      .group('payments.id')
      .having('count(gp.id) < payments.installments')
  }

  def self.slip_expiration_weekdays
    connection.select_one('SELECT public.slip_expiration_weekdays()')['slip_expiration_weekdays'].to_i
  end

  def slip_expiration_date
    # If payment does not exist gives expiration date based on current_timestamp
    if id.nil?
      self.class.connection.select_one("SELECT public.weekdays_from(public.slip_expiration_weekdays(), current_timestamp::timestamp) at time zone 'America/Sao_Paulo' as weekdays_from")['weekdays_from'].try(:to_datetime)
    else
      pluck_from_database("slip_expires_at at time zone 'America/Sao_Paulo'").try(:to_datetime)
    end
  end

  def slip_expired?
    pluck_from_database('slip_expired')
  end

  def is_unique_on_contribution
    errors.add(:payment, I18n.t('activerecord.errors.models.payment.duplicate')) if exists_duplicate?
  end

  def project_should_be_online
    return if project && project.open_for_contributions?
    errors.add(:project, I18n.t('contribution.project_should_be_online'))
  end

  before_validation do
    generate_key
    self.value ||= contribution.try(:value)
  end

  scope :waiting_payment, -> { where('payments.waiting_payment') }

  def waiting_payment?
    pluck_from_database('waiting_payment')
  end

  # Check current status on pagarme and
  # move pending payment to deleted state
  def move_to_trash
    if %w[pending waiting_payment].include?(current_transaction_state)
      trash
    else
      change_status_from_transaction
    end
  end

  def generate_key
    self.key ||= SecureRandom.uuid
  end

  def value_should_be_equal_or_greater_than_pledge
    if contribution && self.value < contribution.value
      errors.add(:value, I18n.t('activerecord.errors.models.payment.attributes.value.invalid'))
    end
  end

  def credits?
    gateway == 'Credits'
  end

  def is_credit_card?
    payment_method == 'CartaoDeCredito'
  end

  def slip_payment?
    payment_method == 'BoletoBancario'
  end

  state_machine :state, initial: :pending do
    state :pending
    state :paid
    state :pending_refund
    state :refunded
    state :refused
    state :deleted
    state :chargeback
    state :manual_refund

    event :chargeback do
      transition [:paid, :refunded] => :chargeback
    end

    event :trash do
      transition %i[pending paid refunded refused] => :deleted
    end

    event :pay do
      transition %i[pending pending_refund chargeback refunded refused] => :paid,
                 unless: ->(payment) { payment.is_donation? }
    end

    event :refuse do
      transition %i[pending paid] => :refused
    end

    event :request_refund do
      transition paid: :pending_refund
    end

    event :refund do
      transition %i[pending_refund paid deleted] => :refunded
    end

    event :manual_refund do
      transition %i[pending_refund paid deleted] => :manual_refund
    end

    after_transition do |payment, transition|
      payment.notify_observers :"from_#{transition.from}_to_#{transition.to}"

      to_column = "#{transition.to}_at".to_sym
      payment.update_attribute(to_column, DateTime.current) if payment.has_attribute?(to_column)
    end
  end

  def can_request_refund?
    !contribution.balance_refunded? && paid?
  end

  def notify_about_pending_review
    contribution.notify_to_contributor(:payment_card_pending_review) if is_credit_card? && gateway_data && pending?
  end

  private

  def exists_duplicate?
    contribution.payments.where('id is not null').exists? unless generating_second_slip
  end

  def pluck_from_database(field)
    Payment.where(id: id).pluck("payments.#{field}").first
  end
end
