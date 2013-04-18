# coding: utf-8
class Backer < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper
  schema_associations
  validates_presence_of :project, :user, :value
  validates_numericality_of :value, :greater_than_or_equal_to => 10.00
  validate :reward_must_be_from_project
  scope :by_id, ->(id) { where(id: id) }
  scope :by_key, ->(key) { where(key: key) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :project_name_contains, ->(term) { joins(:project).where("unaccent(upper(projects.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :anonymous, where(:anonymous => true)
  scope :credits, where(:credits => true)
  scope :requested_refund, where(:requested_refund => true)
  scope :refunded, where(:refunded => true)
  scope :not_anonymous, where(:anonymous => false)
  scope :confirmed, where(:confirmed => true)
  scope :not_confirmed, where(:confirmed => false) # used in payment engines
  scope :in_time_to_confirm, ->() { 
    where(%Q{
      case when lower(payment_choice) = 'debitobancario' then
        date(current_timestamp) <= date(created_at + interval '1 days')
      else
        date(current_timestamp) <= date(created_at + interval '5 days')
      end and not confirmed and payment_token is not null
    }) 
  }
  scope :pending_to_refund, ->() { where("confirmed and requested_refund and not refunded") }

  # Backers already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{
    where(%Q{
      confirmed AND
      EXISTS(
        SELECT true
          FROM projects p
          WHERE p.id = backers.project_id and p.state = 'failed'
      ) AND
      date(current_timestamp) <= date(created_at + interval '180 days')
    })
  }

  attr_protected :confirmed

  def refund_deadline
    created_at + 180.days
  end

  def change_reward! reward
    self.reward_id = reward
    self.save
  end

  def confirm!
    self.confirmed = true
    self.save
  end

  def unconfirm!
    self.confirmed = false
    self.save
  end
  
  def refund!
    self.refunded = true
    self.save
  end

  def can_refund?
    confirmed? && created_at >= (Date.today - 180.days) && project.finished? && !project.successful?
  end

  def reward_must_be_from_project
    return unless reward
    errors.add(:reward, I18n.t('backer.reward_must_be_from_project')) unless reward.project == project
  end

  validate :value_must_be_at_least_rewards_value

  def value_must_be_at_least_rewards_value
    return unless reward
    errors.add(:value, I18n.t('backer.value_must_be_at_least_rewards_value', :minimum_value => reward.display_minimum)) unless value >= reward.minimum_value
  end

  validate :should_not_back_if_maximum_backers_been_reached, :on => :create

  def should_not_back_if_maximum_backers_been_reached
    return unless reward and reward.maximum_backers and reward.maximum_backers > 0
    errors.add(:reward, I18n.t('backer.should_not_back_if_maximum_backers_been_reached')) unless reward.backers.confirmed.count < reward.maximum_backers
  end

  def display_value
    number_to_currency value, :unit => "R$", :precision => 0, :delimiter => '.'
  end

  def available_rewards
    Reward.where(project_id: self.project_id).where('minimum_value <= ?', self.value).order(:minimum_value)
  end

  def display_confirmed_at
    I18n.l(confirmed_at.to_date) if confirmed_at
  end

  def platform_fee(fee=7.5)
    (value.to_f * fee)/100
  end

  def display_platform_fee(fee=7.5)
    number_to_currency platform_fee(fee), :unit => "R$", :precision => 2, :delimiter => ','
  end

  def as_json(options={})
    json_attributes = {
      :id => id,
      :anonymous => anonymous,
      :confirmed => confirmed,
      :confirmed_at => display_confirmed_at,
      :value => display_value,
      :user => user.as_json(options.merge(:anonymous => anonymous)),
      :display_value => nil,
      :reward => nil
    }
    if options and options[:can_manage]
      json_attributes.merge!({
        :display_value => display_value,
        :reward => reward
      })
    end
    if options and options[:include_project]
      json_attributes.merge!({:project => project})
    end
    if options and options[:include_reward]
      json_attributes.merge!({:reward => reward})
    end
    json_attributes
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
