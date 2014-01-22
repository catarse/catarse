# coding: utf-8
class Reward < ActiveRecord::Base
  include RankedModel

  include ERB::Util
  schema_associations
  has_many :contributions, dependent: :nullify

  ranks :row_order, with_same: :project_id
  has_paper_trail

  validates_presence_of :minimum_value, :description, :days_to_delivery
  validates_numericality_of :minimum_value, greater_than_or_equal_to: 10.00
  validates_numericality_of :maximum_contributions, only_integer: true, greater_than: 0, allow_nil: true
  scope :remaining, -> { where("maximum_contributions IS NULL OR (maximum_contributions IS NOT NULL AND (SELECT COUNT(*) FROM contributions WHERE state IN ('confirmed', 'waiting_confirmation') AND reward_id = rewards.id) < maximum_contributions)") }
  scope :sort_asc, -> { order('id ASC') }

  delegate :display_deliver_estimate, :display_remaining, :name, :display_minimum, :short_description,
           :medium_description, :last_description, :display_description, to: :decorator
  def decorator
    @decorator ||= RewardDecorator.new(self)
  end

  def has_modification?
    versions.count > 1
  end

  def sold_out?
    maximum_contributions && total_compromised >= maximum_contributions
  end

  def total_compromised
    contributions.with_states(['confirmed', 'waiting_confirmation']).count
  end

  def remaining
    return nil unless maximum_contributions
    maximum_contributions - total_compromised
  end
end
