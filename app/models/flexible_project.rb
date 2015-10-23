class FlexibleProject < ActiveRecord::Base
  include Project::FlexibleStateValidator

  belongs_to :project
  has_many :transitions,
    class_name: 'FlexibleProjectTransition',
    autosave: false

  # ensure that we have only one flexible project per project
  validates :project_id, presence: true, uniqueness: true

  # instace of a flexible project state machine
  def state_machine
    @state_machine ||= FlexibleProjectMachine.new(self, {
      transition_class: FlexibleProjectTransition,
      association_name: :transitions
    })
  end
end
