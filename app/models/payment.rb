class Payment < ActiveRecord::Base
  DUPLICATION_PERIOD = '30 minutes'
  SLIP_EXPIRATION_WEEKDAYS = 2

  include Shared::StateMachineHelpers
  include Payment::PaymentEngineHandler
  include Payment::RequestRefundHandler

  delegate :user, :project, :invalid_refund, :notify_to_backoffice, :is_donation?,  to: :contribution

  belongs_to :contribution
  has_many :payment_notifications # to keep compatibility with catarse_pagarme
  has_many :payment_transfers

  validates_presence_of :state, :key, :gateway, :payment_method, :value, :installments, :contribution_id
  validate :value_should_be_equal_or_greater_than_pledge
  validate :project_should_be_online, on: :create
  validate :is_unique_within_period, on: :create

  def slip_expiration_date
    SLIP_EXPIRATION_WEEKDAYS.weekdays_from self.created_at
  end

  def slip_expired?
    slip_expiration_date < Time.zone.now
  end

  def is_unique_within_period
    errors.add(:payment, I18n.t('activerecord.errors.models.payment.duplicate')) if exists_duplicate?
  end

  def project_should_be_online
    return if project && project.open_for_contributions?
    errors.add(:project, I18n.t('contribution.project_should_be_online'))
  end

  before_validation do
    generate_key
    self.value ||= self.contribution.try(:value)
  end

  scope :waiting_payment, -> { where('payments.waiting_payment') }


  def waiting_payment?
    Payment.where(id: self.id).pluck("payments.waiting_payment").first
  end
  # Check current status on pagarme and
  # move pending payment to deleted state
  def move_to_trash
    if ['pending', 'waiting_payment'].include?(self.current_transaction_state)
      self.trash
    else
      self.change_status_from_transaction
    end
  end

  def generate_key
    self.key ||= SecureRandom.uuid
  end

  def value_should_be_equal_or_greater_than_pledge
    if self.contribution && self.value < self.contribution.value
      errors.add(:value, I18n.t("activerecord.errors.models.payment.attributes.value.invalid"))
    end
  end

  def notification_template_for_failed_project
    if slip_payment?
      self.user.bank_account.present? ? :contribution_project_unsuccessful_slip : :contribution_project_unsuccessful_slip_no_account
    else
      :contribution_project_unsuccessful_credit_card
    end
  end


  def credits?
    self.gateway == 'Credits'
  end

  def is_credit_card?
    self.payment_method == 'CartaoDeCredito'
  end

  def slip_payment?
    self.payment_method == 'BoletoBancario'
  end

  state_machine :state, initial: :pending do
    state :pending
    state :paid
    state :pending_refund
    state :refunded
    state :refused
    state :deleted
    state :chargeback

    event :chargeback do
      transition [:paid] => :chargeback
    end

    event :trash do
      transition [:pending, :paid, :refunded, :refused] => :deleted
    end

    event :pay do
      transition [:pending, :pending_refund, :chargeback, :refunded] => :paid
    end

    event :refuse do
      transition [:pending, :paid] => :refused
    end

    event :request_refund do
      transition paid: :pending_refund
    end

    event :refund do
      transition [:pending_refund, :paid, :deleted] => :refunded
    end

    after_transition do |payment, transition|
      payment.notify_observers :"from_#{transition.from}_to_#{transition.to}"

      to_column = "#{transition.to}_at".to_sym
      payment.update_attribute(to_column, DateTime.current) if payment.has_attribute?(to_column)
    end
  end

  def can_request_refund?
    !self.slip_payment? || self.user.try(:bank_account).try(:valid?)
  end

  private
  def exists_duplicate?
    self.contribution.payments.
      where(payment_method: self.payment_method, value: self.value).
      where("current_timestamp - payments.created_at < '#{DUPLICATION_PERIOD}'::interval").
      exists?
  end
end
