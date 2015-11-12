# -*- coding: utf-8 -*-
# This module handles with default project state validation
module Project::BaseValidator
  extend ActiveSupport::Concern

  included do
    # All valid states for projects in_analysis to end of publication
    ON_ANALYSIS_TO_END_STATES = %w(in_analysis approved online successful waiting_funds failed).freeze

    # All valid states for projects approved to end of publication
    ON_ONLINE_TO_END_STATES = %w(online successful waiting_funds failed).freeze

    # Start validations when project state
    # is included on ON_ANALYSIS_TO_END_STATE
    with_options if: -> (x) { ON_ANALYSIS_TO_END_STATES.include? x.state } do |wo| 
      wo.validates_presence_of :about_html, :headline, :budget

      wo.validates_presence_of :uploaded_image,
        unless: ->(project) { project.video_thumbnail.present? }

      wo.validate do
        [:uploaded_image, :about_html, :name].each do |attr|
          self.user.errors.add_on_blank(attr)
        end

        self.user.errors.each do |error, error_message|
          self.errors.add('user.' + error.to_s, error_message)
        end

        if self.account && (self.account.agency.try(:size) || 0) < 4
          self.errors['account.agency_size'] << "Agência deve ter pelo menos 4 dígitos"
        end
      end
    end
  end
end
