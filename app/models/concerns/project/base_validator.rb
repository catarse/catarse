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
      wo.validates_presence_of :about_html, :headline
      wo.validates_presence_of :goal, unless: ->(project) { project.mode == 'sub' }


      wo.validates_presence_of :uploaded_image, unless: ->(project) { project.video_thumbnail.present? }

      wo.validates :content_rating, inclusion: [1, 18], presence: true, on: :update

      wo.validate do
        user.publishing_project = true
        user.valid?
        user.errors.each do |error|
          errors.add('user.' + error.attribute.to_s, error.message)
        end
      end

      wo.validate do |project|
        errors.add(
          'goals.size',
          I18n.t('activerecord.errors.models.project.attributes.goals.at_least_one')
        ) if project.goals.all?(&:marked_for_destruction?) && project.is_sub?
      end

      wo.validates_presence_of :budget, unless: ->(project) { project.mode == 'sub' }
    end
  end
end
