# coding: utf-8
class Backer < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :reward
  validates_presence_of :project, :user, :value
  validates_numericality_of :value, :greater_than_or_equal_to => 10.00
  validate :reward_must_be_from_project
  def reward_must_be_from_project
    return unless reward
    errors.add(:reward, "deve ser do mesmo projeto") unless reward.project == project
  end
  validate :value_must_be_at_least_rewards_value
  def value_must_be_at_least_rewards_value
    return unless reward
    errors.add(:value, "deve ser pelo menos #{reward.minimum_value} para a recompensa selecionada") unless value >= reward.minimum_value
  end
  validate :should_not_back_if_maximum_backers_been_reached
  def should_not_back_if_maximum_backers_been_reached
    return unless reward and reward.maximum_backers and reward.maximum_backers > 0
    errors.add(:reward, "já atingiu seu número máximo de apoiadores") unless reward.backers.count < reward.maximum_backers
  end
end
