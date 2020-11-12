# frozen_string_literal: true

module Project::CustomValidators
  extend ActiveSupport::Concern

  included do
    @@routes = Rails.application.routes.routes
    validate :permalink_cant_be_route
    # This code might come back in a near future
    # validate :ensure_at_least_one_reward_validation, unless: :is_flexible?
    validate :validate_tags
    validate :no_base64_images

    def validate_tags
      errors.add(:public_tags, :less_than_or_equal_to, count: 5) if public_tags.size > 5
    end

    def self.get_routes
      @@mapped_routes ||= @@routes.each_with_object(Set.new) do |item, memo|
        memo << Regexp.last_match(1) if item.path.spec.to_s.match(/^\/([\w]+)\S/)
      end
    end

    def self.permalink_on_routes?(permalink)
      permalink && get_routes.include?(permalink.downcase)
    end

    def permalink_cant_be_route
      errors.add(:permalink, I18n.t('activerecord.errors.models.project.attributes.permalink.invalid')) if Project.permalink_on_routes?(permalink)
    end

    def ensure_at_least_one_reward_validation
      if rewards.empty?
        errors.add(
          'rewards.size',
          I18n.t('activerecord.errors.models.project.attributes.rewards.at_least_one')
        )
      end
    end

    def no_base64_images
      errors.add(:about_html, :base64_images_not_allowed) if about_html.try(:match?, 'data:image/.*;base64')
      errors.add(:budget, :base64_images_not_allowed) if budget.try(:match?, 'data:image/.*;base64')
    end

  end
end
