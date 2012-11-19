# coding: utf-8
class Backer < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper
  belongs_to :project
  belongs_to :user
  belongs_to :reward
  has_many :payment_notifications
  validates_presence_of :project, :user, :value
  validates_numericality_of :value, :greater_than_or_equal_to => 10.00
  validate :reward_must_be_from_project
  scope :anonymous, where(:anonymous => true)
  scope :not_anonymous, where(:anonymous => false)
  scope :confirmed, where(:confirmed => true)
  scope :not_confirmed, where(:confirmed => false)
  scope :pending, where(:confirmed => false)

  # Backers already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{ where("confirmed AND EXISTS(SELECT true FROM projects p WHERE p.id = backers.project_id AND finished AND NOT successful) AND date(current_timestamp) <= date(created_at + interval '180 days')") }
  attr_protected :confirmed

  def price_in_cents
    (self.value * 100).round
  end

  def refund!
    self.refunded = true
    self.save
  end

  def refund_deadline
    created_at + 180.days
  end

  def confirm!
    self.confirmed = true
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

  def display_confirmed_at
    I18n.l(confirmed_at.to_date) if confirmed_at
  end

  def platform_fee(fee=7.5)
    (value.to_f * fee)/100
  end

  def display_platform_fee(fee=7.5)
    number_to_currency platform_fee(fee), :unit => "R$", :precision => 2, :delimiter => '.'
  end

  def moip_value
    "%0.0f" % (value * 100)
  end

  def cancel_refund_request!
    raise I18n.t('credits.cannot_cancel_refund_reques') unless self.requested_refund
    raise I18n.t('credits.refund.refunded') if self.refunded
    raise I18n.t('credits.refund.no_credits') unless self.user.credits >= self.value
    self.update_attributes({ requested_refund: false })
    self.user.update_attributes({ credits: (self.user.credits + self.value) })
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

  #==== Used on before and after callbacks

  def define_key
    self.update_attributes({ key: Digest::MD5.new.update("#{self.id}###{self.created_at}###{Kernel.rand}").to_s })
  end

  def define_payment_method
    self.update_attributes({ payment_method: 'MoIP' })
  end
end
