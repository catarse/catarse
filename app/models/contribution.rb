# coding: utf-8
class Contribution < ActiveRecord::Base
  has_notifications

  include I18n::Alchemy
  include PgSearch
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
  validates_numericality_of :value, greater_than_or_equal_to: 10.00

  pg_search_scope :search_on_user,
    against: [:payer_email],
    associated_against: {
      user: [:name, :full_name, :email, :id]
    },
    using: {tsearch: {dictionary: "portuguese"}},
    ignoring: :accents

  pg_search_scope :search_on_payment_data,
    against: [:key, :payment_id, :acquirer_tid],
    using: {tsearch: {dictionary: "portuguese"}},
    ignoring: :accents

  pg_search_scope :search_on_acquirer,
    against: [:acquirer_name],
    ignoring: :accents

  scope :available_to_count, ->{ with_states(['confirmed', 'requested_refund', 'refunded']) }
  scope :available_to_display, ->{ with_states(['confirmed', 'requested_refund', 'refunded', 'waiting_confirmation']) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_payment_id, ->(term) { where("? IN (payment_id, key, acquirer_tid)", term) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :by_payment_method, ->(payment_method) { where(payment_method: payment_method ) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_email_contains, ->(term) { joins(:user).where("unaccent(upper(users.email)) LIKE ('%'||unaccent(upper(?))||'%') OR unaccent(upper(payer_email)) LIKE ('%'||unaccent(upper(?))||'%')", term, term) }
  scope :project_name_contains, ->(term) {
    joins(:project).merge(Project.search_on_name(term))
  }
  scope :anonymous, -> { where(anonymous: true) }
  scope :credits, -> { where("credits OR lower(payment_method) = 'credits'") }
  scope :not_anonymous, -> { where(anonymous: false) }
  scope :confirmed_today, -> { with_state('confirmed').where("contributions.confirmed_at::date = to_date(?, 'yyyy-mm-dd')", Time.now.strftime('%Y-%m-%d')) }
  scope :avaiable_to_automatic_refund, -> {
    with_state('confirmed').where("contributions.payment_method in ('PayPal', 'Pagarme') OR contributions.payment_choice = 'CartaoDeCredito'")
  }

  scope :not_created_today, -> { where.not("contributions.created_at::date AT TIME ZONE '#{Time.zone.tzinfo.name}' = current_timestamp::date AT TIME ZONE '#{Time.zone.tzinfo.name}'") }
  scope :can_cancel, -> { where("contributions.can_cancel") }

  # Contributions already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{ where("contributions.can_refund") }

  scope :for_successful_projects, -> {
    joins(:project).merge(Project.with_state('successful')).with_state(['waiting_confirmation', 'confirmed', 'refunded', 'requested_refund', 'refunded_and_canceled'])
  }

  scope :for_online_projects, -> {
    joins(:project).merge(Project.with_state(['online', 'waiting_funds'])).with_state(['waiting_confirmation', 'confirmed', 'refunded', 'requested_refund', 'refunded_and_canceled'])
  }

  scope :for_failed_projects, -> {
    joins(:project).merge(Project.with_state('failed')).with_state(['waiting_confirmation', 'confirmed', 'refunded', 'requested_refund', 'refunded_and_canceled'])
  }

  scope :ordered, -> { order(id: :desc) }

  attr_protected :state, :user_id

  def self.between_values(start_at, ends_at)
    return all unless start_at.present? && ends_at.present?
    where("value between ? and ?", start_at, ends_at)
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

  def invalid_refund
    _user = User.find_by(email: CatarseSettings[:email_contact])
    notify(:invalid_refund, _user, self) if _user
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

  def notification_template_for_failed_project
    return :contribution_project_unsuccessful_credit if self.credits?

    if is_credit_card? || is_paypal?
      :contribution_project_unsuccessful_credit_card
    elsif is_pagarme?
      :contribution_project_unsuccessful_slip
    else
      :contribution_project_unsuccessful
    end
  end

  def self.payment_method_names
    ['Pagarme', 'PayPal', 'MoIP']
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
