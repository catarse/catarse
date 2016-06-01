# -*- coding: utf-8 -*-
# This module handles with default state validation
module Project::AllOrNothingStateValidator
  extend ActiveSupport::Concern

  included do
    with_options if: ->(x) { x.mode == 'aon' } do |wg| 
      # Validation for in_analysis? only state
      wg.with_options if: :online? do |wo|
        wo.validates_presence_of :city
        wo.validates_length_of :name, maximum: Project::NAME_MAXLENGTH
      end

      # Start validations when project state
      # is included on ON_ANALYSIS_TO_END_STATE
      wg.with_options if: -> (x) { ( Project::ON_ANALYSIS_TO_END_STATES.include? x.state ) && ( x.mode == 'aon' ) } do |wo| 
        wo.validates_presence_of :goal, :online_days, :budget
      end
    end
  end
end
