class Payment < ActiveRecord::Base
  include Shared::StateMachineHelpers
  include Payment::PaymentEngineHandler
  delegate :user, :project, :invalid_refund, to: :contribution

  belongs_to :contribution
  has_many :payment_notifications # to keep compatibility with catarse_pagarme

  validates_presence_of :state, :key, :gateway, :payment_method, :value, :installments
  validate :value_should_be_equal_or_greater_than_pledge

  before_validation do
    generate_key
    self.value ||= self.contribution.try(:value)
  end

  scope :can_delete, ->{ with_state('pending').where("current_timestamp - payments.created_at > '1 week'::interval") }

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
      transition all => :chargeback
    end

    event :trash do
      transition all => :deleted
    end

    event :pay do
      transition all => :paid
    end

    event :refuse do
      transition all => :refused
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
end
