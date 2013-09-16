require 'state_machine'
# coding: utf-8
class Backer < ActiveRecord::Base
  schema_associations

  delegate :display_value, :display_confirmed_at, to: :decorator

  validates_presence_of :project, :user, :value
  validates_numericality_of :value, greater_than_or_equal_to: 10.00
  validate :reward_must_be_from_project
  validate :value_must_be_at_least_rewards_value
  validate :should_not_back_if_maximum_backers_been_reached, on: :create
  validate :project_should_be_online, on: :create

  scope :available_to_count, ->{ with_states(['confirmed', 'requested_refund', 'refunded']) }
  scope :available_to_display, ->{ with_states(['confirmed', 'requested_refund', 'refunded', 'waiting_confirmation']) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_key, ->(key) { where(key: key) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :project_name_contains, ->(term) { joins(:project).where("unaccent(upper(projects.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :anonymous, -> { where(anonymous: true) }
  scope :credits, -> { where(credits: true) }
  scope :not_anonymous, -> { where(anonymous: false) }

  scope :can_cancel, -> {
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
      NOT backers.credits AND
      EXISTS(
        SELECT true
          FROM projects p
          WHERE p.id = backers.project_id and p.state = 'failed'
      )
    })
  }

  # TODO:
  #attr_protected :confirmed, :state

  def self.between_values(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("value between ? and ?", start_at, ends_at)
  end

  def self.state_names
    self.state_machine.states.map do |state|
      state.name if state.name != :deleted
    end.compact!
  end

  def decorator
    @decorator ||= BackerDecorator.new(self)
  end

  def recommended_projects
    user.recommended_projects.where("projects.id <> ?", project.id)
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
    return unless reward && reward.maximum_backers && reward.maximum_backers > 0
    errors.add(:reward, I18n.t('backer.should_not_back_if_maximum_backers_been_reached')) if reward.sold_out?
  end

  def project_should_be_online
    return if project && project.online?
    errors.add(:project, I18n.t('backer.project_should_be_online'))
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
      transition confirmed: :requested_refund, if: ->(backer){
        backer.user.credits >= backer.value && !backer.credits
      }
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
