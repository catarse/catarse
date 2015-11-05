class FlexibleProject < ActiveRecord::Base
  include Project::BaseValidator

  belongs_to :project
  has_many :transitions,
    class_name: 'FlexibleProjectTransition',
    autosave: false

  # ensure that we have only one flexible project per project
  validates :project_id, presence: true, uniqueness: true

  # delegate reusable methods from project
  delegate :expired?, :reached_goal?, :in_time_to_wait?,
    :notify_owner, :notify, :user, :payments,
    :headline, :about_html, :budget, :uploaded_image,
    :account, :video_thumbnail, :name, to: :project

  # instace of a flexible project state machine
  def state_machine
    @state_machine ||= FlexibleProjectMachine.new(self, {
      transition_class: FlexibleProjectTransition,
      association_name: :transitions
    })
  end
end
