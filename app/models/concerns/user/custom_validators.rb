# frozen_string_literal: true

module User::CustomValidators
  extend ActiveSupport::Concern

  included do
    validate :no_base64_images, :block_email_with_reference_to_catarse

    def no_base64_images
      errors.add(:about_html, :base64_images_not_allowed) if about_html.try(:match?, 'data:image/.*;base64')
    end

    def block_email_with_reference_to_catarse
      return unless email.present? && email_changed?
      if email.split('@').last.try(:include?, 'catarse')
        errors.add(:email, :invalid)
        raise ActiveRecord::Rollback
      end
    end
  end
end
