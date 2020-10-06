# frozen_string_literal: true

module User::CustomValidators
  extend ActiveSupport::Concern

  included do
    validate :no_base64_images

    def no_base64_images
      errors.add(:about_html, :base64_images_not_allowed) if about_html.try(:match?, 'data:image/.*;base64')
    end
  end
end
