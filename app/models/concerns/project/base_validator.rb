# -*- coding: utf-8 -*-
# This module handles with default project state validation
module Project::BaseValidator
  extend ActiveSupport::Concern

  included do
    ON_ONLINE_TO_END_STATES = %w(online successful waiting_funds failed).freeze

    # Validation for online? only state
    with_options if: :online? do |wo|
      wo.validates_presence_of :city
      wo.validates_length_of :name, maximum: Project::NAME_MAXLENGTH
    end

    # Start validations when project state
    # is included on ON_ONLINE_TO_END_STATE
    with_options if: -> (x) { ON_ONLINE_TO_END_STATES.include? x.state } do |wo| 
      wo.validates_presence_of :about_html, :headline, :goal

      wo.validates_presence_of :uploaded_image,
        unless: ->(project) { project.video_thumbnail.present? }

      wo.validate do
        [:uploaded_image, :about_html, :public_name].each do |attr|
          self.user.errors.add_on_blank(attr)
        end

        self.user.errors.each do |error, error_message|
          self.errors.add('user.' + error.to_s, error_message)
        end
      end

      wo.validates_presence_of :budget
      wo.validates_presence_of :account, message: 'Dados Bancários não podem ficar em branco'		

      wo.validates_numericality_of :online_days, less_than_or_equal_to: 365, greater_than_or_equal_to: 1, allow_nil: true

      wo.validate do
        if self.online_days.present? && self.rewards.any?(&:invalid_deliver_at?)
          self.errors['rewards.deliver_at'] << "Existe uma ou mais recompensas com o prazo de entrega menor que a data do fim do projeto"
        end
      end
      wo.validate do
        if self.account && (self.account.agency.try(:size) || 0) < 4
          self.errors['account.agency_size'] << "Agência deve ter pelo menos 4 dígitos"
        end
      end
    end
  end
end
