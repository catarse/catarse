# frozen_string_literal: true

class ProjectTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :project, inverse_of: :project_transitions
end
