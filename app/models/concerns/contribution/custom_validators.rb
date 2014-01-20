module Contribution::CustomValidators
  extend ActiveSupport::Concern

  included do
    validate :reward_must_be_from_project
    validate :value_must_be_at_least_rewards_value
    validate :should_not_back_if_maximum_contributions_been_reached, on: :create
    validate :project_should_be_online, on: :create

    def reward_must_be_from_project
      return unless reward
      errors.add(:reward, I18n.t('contribution.reward_must_be_from_project')) unless reward.project == project
    end

    def value_must_be_at_least_rewards_value
      return unless reward
      errors.add(:value, I18n.t('contribution.value_must_be_at_least_rewards_value', minimum_value: reward.display_minimum)) unless value.to_f >= reward.minimum_value
    end

    def should_not_back_if_maximum_contributions_been_reached
      return unless reward && reward.maximum_contributions && reward.maximum_contributions > 0
      errors.add(:reward, I18n.t('contribution.should_not_back_if_maximum_contributions_been_reached')) if reward.sold_out?
    end

    def project_should_be_online
      return if project && project.online?
      errors.add(:project, I18n.t('contribution.project_should_be_online'))
    end

  end
end
