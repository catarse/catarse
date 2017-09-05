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
      has_error = false
      value_to_validate = ((shipping_fee.try(:value)||0) + reward.minimum_value)
      if !%w(free presential).include?(reward.shipping_options) && reward.shipping_fees.present? && !shipping_fee.present?
        has_error = true
      end

      if value.to_f < value_to_validate
        has_error = true
      end

      errors.add(:value, I18n.t('contribution.value_must_be_at_least_rewards_value', minimum_value: value_to_validate)) if has_error
    end

    def should_not_contribute_if_maximum_contributions_been_reached
      return unless reward && reward.maximum_contributions && reward.maximum_contributions > 0
      errors.add(:reward, I18n.t('contribution.should_not_contribute_if_maximum_contributions_been_reached')) if reward.sold_out?
    end
  end
end
