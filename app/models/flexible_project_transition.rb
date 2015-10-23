class FlexibleProjectTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :flexible_project, inverse_of: :transitions
end
