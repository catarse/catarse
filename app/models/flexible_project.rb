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

  # delegate reusable methods from state_machine
  delegate :push_to_online, :finish, :push_to_draft,
    :push_to_trash, :reject, to: :state_machine

  # instace of a flexible project state machine
  def state_machine
    @state_machine ||= FlexProjectMachine.new(self, {
      transition_class: FlexibleProjectTransition,
      association_name: :transitions
    })
  end

  # gen state method helpers ex(online?, draft?)
  %w(
    draft rejected online successful waiting_funds deleted
  ).each do |st|
    define_method "#{st}?" do
      if self.state.nil?
        self.state_machine.current_state == st
      else
        self.state == st
      end
    end
  end

end
