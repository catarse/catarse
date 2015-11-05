class ProjectTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition


  belongs_to :project, inverse_of: :project_transitions
end
