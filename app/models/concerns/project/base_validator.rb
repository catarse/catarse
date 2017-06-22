# -*- coding: utf-8 -*-
# frozen_string_literal: true

# This module handles with default project state validation
module Project::BaseValidator
  extend ActiveSupport::Concern

  included do
    ON_ONLINE_TO_END_STATES = %w[online successful waiting_funds failed].freeze

    # Validation for online? only state
    with_options if: :online? do |wo|
      wo.validates_presence_of :city
      wo.validates_length_of :name, maximum: Project::NAME_MAXLENGTH
    end

    # Start validations when project state
    # is included on ON_ONLINE_TO_END_STATE
    with_options if: ->(x) { ON_ONLINE_TO_END_STATES.include? x.state } do |wo|
      validates_numericality_of :online_days, less_than_or_equal_to: 365, greater_than_or_equal_to: 1, allow_nil: true, if: :is_flexible?
      wo.validates_presence_of :about_html, :headline, :goal

      wo.validates_presence_of :uploaded_image,
                               unless: ->(project) { project.video_thumbnail.present? }

      wo.validate do
        user.publishing_project = true
        user.valid?
        user.errors.each do |error, error_message|
          errors.add('user.' + error.to_s, error_message)
        end
      end

      wo.validates_presence_of :budget
    end
  end
end
