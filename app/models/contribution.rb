# coding: utf-8
class Contribution < ActiveRecord::Base
  schema_associations

  include Shared::StateMachineHelpers
  include Contribution::StateMachineHandler
  include Contribution::CustomValidators
  include Contribution::PaymentEngineHandler

  delegate :display_value, :display_confirmed_at, to: :decorator

  validates_presence_of :project, :user, :value
  validates_numericality_of :value, greater_than_or_equal_to: 10.00

  scope :available_to_count, ->{ with_states(['confirmed', 'requested_refund', 'refunded']) }
  scope :available_to_display, ->{ with_states(['confirmed', 'requested_refund', 'refunded', 'waiting_confirmation']) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_key, ->(key) { where(key: key) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_email_contains, ->(term) { joins(:user).where("unaccent(upper(users.email)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :payer_email_contains, ->(term) { where("unaccent(upper(payer_email)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :project_name_contains, ->(term) { joins(:project).where("unaccent(upper(projects.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :anonymous, -> { where(anonymous: true) }
  scope :credits, -> { where("credits OR lower(payment_method) = 'credits'") }
  scope :not_anonymous, -> { where(anonymous: false) }
  scope :confirmed_today, -> { with_state('confirmed').where("contributions.confirmed_at::date = current_date ") }

  scope :can_cancel, -> { where("contributions.can_cancel") }

  # Contributions already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{ where("contributions.can_refund") }

  attr_protected :state, :user_id

  def self.between_values(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("value between ? and ?", start_at, ends_at)
  end

  def slip_payment?
    payment_choice.try(:downcase) == 'boletobancario'
  end

  def decorator
    @decorator ||= ContributionDecorator.new(self)
  end

  def recommended_projects
    user.recommended_projects.where("projects.id <> ?", project.id).order("count DESC")
  end

  def refund_deadline
    created_at + 180.days
  end

  def change_reward! reward
    self.reward_id = reward
    self.save
  end

  def can_refund?
    confirmed? && project.failed?
  end

  def available_rewards
    Reward.where(project_id: self.project_id).where('minimum_value <= ?', self.value).order(:minimum_value)
  end

  def update_current_billing_info
    self.address_street = user.address_street
    self.address_number = user.address_number
    self.address_neighbourhood = user.address_neighbourhood
    self.address_zip_code = user.address_zip_code
    self.address_city = user.address_city
    self.address_state = user.address_state
    self.address_phone_number = user.phone_number
    self.payer_document = user.cpf
    self.payer_name = user.display_name
  end

  def update_user_billing_info
    user.update_attributes({
      address_street: address_street,
      address_number: address_number,
      address_neighbourhood: address_neighbourhood,
      address_zip_code: address_zip_code,
      address_city: address_city,
      address_state: address_state,
      phone_number: address_phone_number,
      cpf: payer_document
    })
  end

  def notify_to_contributor(template_name)
    Notification.notify_once(template_name,
      self.user,
      { contribution_id: self.id },
      contribution: self
    )
  end

  # Used in payment engines
  def price_in_cents
    (self.value * 100).round
  end

  #==== Used on before and after callbacks

  def define_key
    self.update_attributes({ key: Digest::MD5.new.update("#{self.id}###{self.created_at}###{Kernel.rand}").to_s })
  end
end
