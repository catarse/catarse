# -*- coding: utf-8 -*-
# frozen_string_literal: true

# This module handles with default state validation
module Project::AllOrNothingStateValidator
  extend ActiveSupport::Concern

  included do
    with_options if: ->(x) { x.mode == 'aon' } do |wg|
      # Start validations when project state
      # is included on ON_ONLINE_TO_END_STATE
      wg.with_options if: ->(x) { (Project::ON_ONLINE_TO_END_STATES.include? x.state) && (x.mode == 'aon') } do |wo|
        wo.validates_presence_of :goal, :online_days, :budget
        wo.validates_numericality_of :online_days, less_than_or_equal_to: 60, greater_than_or_equal_to: 1
      end
    end
  end
end
