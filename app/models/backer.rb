require 'state_machine'
# coding: utf-8
class Backer < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  schema_associations

  validates_presence_of :project, :user, :value
  validates_numericality_of :value, greater_than_or_equal_to: 10.00
  validate :reward_must_be_from_project
  validate :value_must_be_at_least_rewards_value
  validate :should_not_back_if_maximum_backers_been_reached, on: :create
  validate :project_should_be_online, on: :create

  scope :not_deleted, ->() { where("backers.state <> 'deleted'") }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_key, ->(key) { where(key: key) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :project_name_contains, ->(term) { joins(:project).where("unaccent(upper(projects.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :anonymous, where(anonymous: true)
  scope :credits, where(credits: true)
  scope :requested_refund, where(state: 'requested_refund')
  scope :refunded, where(state: 'refunded')
  scope :not_anonymous, where(anonymous: false)
  scope :confirmed, where(state: 'confirmed')
  scope :not_confirmed, where("backers.state <> 'confirmed'") # used in payment engines
  scope :in_time_to_confirm, ->() { where(state: 'waiting_confirmation') }
  scope :pending_to_refund, ->() { where(state: 'requested_refund') }

  scope :available_to_count, ->() { where("state in ('confirmed', 'requested_refund', 'refunded')") }

  scope :can_cancel, ->() {
    where(%Q{
      backers.state = 'waiting_confirmation' and
        (
          ((
            select count(1) as total_of_days
            from generate_series(created_at::date, current_date, '1 day') day
            WHERE extract(dow from day) not in (0,1)
          )  > 4)
          OR
          (
            payment_choice = 'DebitoBancario'
            AND
              (
                select count(1) as total_of_days
                from generate_series(created_at::date, current_date, '1 day') day
                WHERE extract(dow from day) not in (0,1)
              )  > 1)
        )
    })
  }

  # Backers already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{
    where(%Q{
      backers.state IN('confirmed', 'requested_refund', 'refunded') AND
      EXISTS(
        SELECT true
          FROM projects p
          WHERE p.id = backers.project_id and p.state = 'failed'
      )
    })
  }

  attr_protected :confirmed, :state

  def self.between_values(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("value between ? and ?", start_at, ends_at)
  end

  def self.state_names
    self.state_machine.states.map do |state|
      state.name if state.name != :deleted
    end.compact!
  end

  def self.send_credits_notification
    confirmed.joins(:project).joins(:user).find_each do |backer|
      if backer.project.state == 'failed' && ((backer.project.expires_at + 1.month) < Time.now) && backer.user.credits >= backer.value
        Notification.create_notification_once(:credits_warning,
          backer.user,
          {backer_id: backer.id},
          backer: backer,
          amount: backer.user.credits
                                             )
      end
    end
  end

  def refund_deadline
    created_at + 180.days
  end

  def change_reward! reward
    self.reward_id = reward
    self.save
  end

  def can_refund?
    confirmed? && project.finished? && !project.successful?
  end

  def reward_must_be_from_project
    return unless reward
    errors.add(:reward, I18n.t('backer.reward_must_be_from_project')) unless reward.project == project
  end

  def value_must_be_at_least_rewards_value
    return unless reward
    errors.add(:value, I18n.t('backer.value_must_be_at_least_rewards_value', minimum_value: reward.display_minimum)) unless value >= reward.minimum_value
  end

  def should_not_back_if_maximum_backers_been_reached
    return unless reward and reward.maximum_backers and reward.maximum_backers > 0
    errors.add(:reward, I18n.t('backer.should_not_back_if_maximum_backers_been_reached')) unless reward.backers.confirmed.count < reward.maximum_backers
  end

  def project_should_be_online
    return if project && project.online?
    errors.add(:project, I18n.t('backer.project_should_be_online'))
  end

  def display_value
    number_to_currency value
  end

  def available_rewards
    Reward.where(project_id: self.project_id).where('minimum_value <= ?', self.value).order(:minimum_value)
  end

  def display_confirmed_at
    I18n.l(confirmed_at.to_date) if confirmed_at
  end

  def as_json(options={})
    json_attributes = {
      id: id,
      anonymous: anonymous,
      confirmed: confirmed?,
      confirmed_at: display_confirmed_at,
      user: user.as_json(options.merge(anonymous: anonymous)),
      value: nil,
      display_value: nil,
      reward: nil
    }
    if options and options[:can_manage]
      json_attributes.merge!({
        value: display_value,
        display_value: display_value,
        reward: reward
      })
    end
    if options and options[:include_project]
      json_attributes.merge!({project: project})
    end
    if options and options[:include_reward]
      json_attributes.merge!({reward: reward})
    end
    json_attributes
  end

  state_machine :state, initial: :pending do
    state :pending, value: 'pending'
    state :waiting_confirmation, value: 'waiting_confirmation'
    state :confirmed, value: 'confirmed'
    state :canceled, value: 'canceled'
    state :refunded, value: 'refunded'
    state :requested_refund, value: 'requested_refund'
    state :refunded_and_canceled, value: 'refunded_and_canceled'
    state :deleted, value: 'deleted'

    event :push_to_trash do
      transition all => :deleted
    end

    event :pendent do
      transition all => :pending
    end

    event :waiting do
      transition pending: :waiting_confirmation
    end

    event :confirm do
      transition all => :confirmed
    end

    event :cancel do
      transition all => :canceled
    end

    event :request_refund do
      transition confirmed: :requested_refund
    end

    event :refund do
      transition [:requested_refund, :confirmed] => :refunded
    end

    event :hide do
      transition all => :refunded_and_canceled
    end

    after_transition confirmed: :requested_refund, do: :after_transition_from_confirmed_to_requested_refund
    after_transition confirmed: :canceled, do: :after_transition_from_confirmed_to_canceled
  end

  def after_transition_from_confirmed_to_canceled
    notify_observers :notify_backoffice_about_canceled
  end

  def after_transition_from_confirmed_to_requested_refund
    notify_observers :notify_backoffice
  end

  # Used in payment engines
  def price_in_cents
    (self.value * 100).round
  end

  #==== Used on before and after callbacks

  def define_key
    self.update_attributes({ key: Digest::MD5.new.update("#{self.id}###{self.created_at}###{Kernel.rand}").to_s })
  end

  def define_payment_method
    self.update_attributes({ payment_method: 'MoIP' })
  end
end
