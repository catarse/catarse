# coding: utf-8
class Contribution < ActiveRecord::Base
  has_notifications

  include Shared::StateMachineHelpers
  include Contribution::StateMachineHandler
  include Contribution::CustomValidators
  include Contribution::PaymentEngineHandler
  include Contribution::PaymentMethods

  delegate :display_value, :display_confirmed_at, :display_slip_url, to: :decorator

  belongs_to :project
  belongs_to :reward
  belongs_to :user
  belongs_to :country
  has_many :payment_notifications

  validates_presence_of :project, :user, :value
  validates_numericality_of :value,
    greater_than_or_equal_to: 10.00,
    unless: -> (contribution) {
      contribution.user.try(:credits).to_f > 0
    }

  scope :available_to_count, ->{ with_states(['confirmed', 'requested_refund', 'refunded']) }
  scope :available_to_display, ->{ with_states(['confirmed', 'requested_refund', 'refunded', 'waiting_confirmation']) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_key, ->(key) { where(key: key) }
  scope :by_payment_id, ->(payment_id) { where(payment_id: payment_id) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_email_contains, ->(term) { joins(:user).where("unaccent(upper(users.email)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :payer_email_contains, ->(term) { where("unaccent(upper(payer_email)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :project_name_contains, ->(term) { joins(:project).where("unaccent(upper(projects.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :anonymous, -> { where(anonymous: true) }
  scope :credits, -> { where("credits OR lower(payment_method) = 'credits'") }
  scope :not_anonymous, -> { where(anonymous: false) }
  scope :confirmed_today, -> { with_state('confirmed').where("contributions.confirmed_at::date = to_date(?, 'yyyy-mm-dd')", Time.now.strftime('%Y-%m-%d')) }
  scope :avaiable_to_automatic_refund, -> {
    with_state('confirmed').where("contributions.payment_method in ('PayPal', 'Pagarme') OR contributions.payment_choice = 'CartaoDeCredito'")
  }

  scope :can_cancel, -> { where("contributions.can_cancel") }

  # Contributions already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{ where("contributions.can_refund") }

  attr_protected :state, :user_id

  def self.between_values(start_at, ends_at)
    return all unless start_at.present? && ends_at.present?
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

  def change_reward! reward
    self.reward_id = reward
    self.save
  end

  def can_refund?
    confirmed? && project.failed?
  end

  def available_rewards
    project.rewards.where('minimum_value <= ?', self.value).order(:minimum_value)
  end

  def notify_to_contributor(template_name, options = {})
    notify_once(template_name, self.user, self, options)
  end

  def notify_to_backoffice(template_name, options = {})
    _user = User.find_by(email: CatarseSettings[:email_payments])
    notify_once(template_name, _user, self, options) if _user
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
