# -*- coding: utf-8 -*-
# This module handles with flexible project state validation
module Project::FlexibleStateValidator
  extend ActiveSupport::Concern

  included do

    # All valid states for flexible_projects
    BASIC_STATS_VALIDATION = %w(online successful waiting_funds).freeze

    # Start validations when project state
    # is included on BASIC_STATS_VALIDATION
    with_options if: -> (x) { BASIC_VALIDATION_STATES.include? x.state } do |wo| 
    end
  end
end
