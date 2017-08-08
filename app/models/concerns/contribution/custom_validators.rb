# frozen_string_literal: true

module Contribution::CustomValidators
  extend ActiveSupport::Concern

  included do
    validate :reward_must_be_from_project
    validate :value_must_be_at_least_rewards_value
    validate :should_not_contribute_if_maximum_contributions_been_reached, on: :create

    def reward_must_be_from_project
      return unless reward
      errors.add(:reward, I18n.t('contribution.reward_must_be_from_project')) unless reward.project == project
    end

    def value_must_be_at_least_rewards_value
      return unless reward
      value_to_validate = reward.minimum_value
      if reward.shipping_fees.present?
        if shipping_fee
          value_to_validate += shipping_fee.value
        else
          errors.add(:value, i18n.t('contribution.value_must_be_at_least_rewards_value', minimum_value: reward.display_minimum))
        end
      end
      errors.add(:value, i18n.t('contribution.value_must_be_at_least_rewards_value', minimum_value: reward.display_minimum)) unless value.to_f >= value_to_validate
    end

    def should_not_contribute_if_maximum_contributions_been_reached
      return unless reward && reward.maximum_contributions && reward.maximum_contributions > 0
      errors.add(:reward, I18n.t('contribution.should_not_contribute_if_maximum_contributions_been_reached')) if reward.sold_out?
    end
  end
end
