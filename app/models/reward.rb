# coding: utf-8
class Reward < ActiveRecord::Base
  include RankedModel
  include ERB::Util

  before_destroy :check_if_is_destroyable

  belongs_to :project
  has_many :contributions, dependent: :nullify

  ranks :row_order, with_same: :project_id

  validates_presence_of :minimum_value, :description, :deliver_at #, :days_to_delivery
  validates_numericality_of :minimum_value, greater_than_or_equal_to: 10.00
  validates_numericality_of :maximum_contributions, only_integer: true, greater_than: 0, allow_nil: true
  validate :deliver_at_cannot_be_in_the_past
  scope :remaining, -> { where("maximum_contributions IS NULL OR (maximum_contributions IS NOT NULL AND (SELECT COUNT(*) FROM contributions WHERE state IN ('confirmed', 'waiting_confirmation') AND reward_id = rewards.id) < maximum_contributions)") }
  scope :sort_asc, -> { order('id ASC') }

  delegate :display_deliver_estimate, :display_remaining, :name, :display_minimum, :short_description,
           :medium_description, :last_description, :display_description, to: :decorator

  before_save :log_changes

  def deliver_at_cannot_be_in_the_past
    self.errors.add(:deliver_at, "Previsão de entrega deve ser superior a data atual") if self.deliver_at < Time.now
  end

  def log_changes
    self.last_changes = self.changes.to_json
  end

  def decorator
    @decorator ||= RewardDecorator.new(self)
  end

  def sold_out?
    maximum_contributions && total_compromised >= maximum_contributions
  end

  def any_sold?
    total_compromised > 0
  end

  def total_compromised
    contributions.with_states(['confirmed', 'waiting_confirmation']).count
  end

  def remaining
    return nil unless maximum_contributions
    maximum_contributions - total_compromised
  end

  def check_if_is_destroyable
    if any_sold?
      project.errors.add 'reward.destroy', "can't destroy"
      return false
    end
  end
end
