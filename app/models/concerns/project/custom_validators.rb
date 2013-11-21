module Project::CustomValidators
  extend ActiveSupport::Concern

  included do
    validate :permalink_cant_be_route, allow_nil: true

    def self.permalink_on_routes?(permalink)
      permalink && self.get_routes.include?(permalink.downcase)
    end

    def permalink_cant_be_route
      errors.add(:permalink, I18n.t("activerecord.errors.models.project.attributes.permalink.invalid")) if Project.permalink_on_routes?(permalink)
    end
  end
end
