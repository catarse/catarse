# frozen_string_literal: true

module Project::CustomValidators
  extend ActiveSupport::Concern

  included do
    @@routes = Rails.application.routes.routes
    validate :permalink_cant_be_route
    # This code might come back in a near future
    # validate :ensure_at_least_one_reward_validation, unless: :is_flexible?
    validate :validate_tags
    validate :solidarity_service_fee

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

    def solidarity_service_fee

      unless !user || user.admin?        
        solidarity_integration = integrations.find { |integration| integration.name === 'SOLIDARITY_SERVICE_FEE' }
        default_service_fee = CatarseSettings[:service_fee] || 0.13
        if service_fee != default_service_fee && solidarity_integration.present?
          min_service_fee = 0.04
          max_service_fee = 0.20
          solidarity_name = solidarity_integration.data['name']
          accepted_fee = service_fee >= min_service_fee && service_fee <= max_service_fee
          errors.add(:service_fee, I18n.t('project.solidarity_service_fee', solidarity_name: solidarity_name, min_service_fee: (min_service_fee * 100).to_i, max_service_fee: (max_service_fee * 100).to_i)) unless accepted_fee
        elsif service_fee != default_service_fee
          errors.add(:service_fee, I18n.t('project.solidarity_service_fee_failed'))
        end
      end

    end
  end
end
