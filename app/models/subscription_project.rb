# frozen_string_literal: true

class SubscriptionProject < Project
  include Project::BaseValidator
  has_many :goals, foreign_key: :project_id

  accepts_nested_attributes_for :goals, allow_destroy: true
  mount_uploader :cover_image, CoverUploader
  # delegate reusable methods from state_machine
  delegate :push_to_online, :push_to_draft,
           :push_to_trash, to: :state_machine

  def self.sti_name
    'sub'
  end

  # instace of a subscription project state machine
  def state_machine
    @state_machine ||= SubProjectMachine.new(self, {
                                                transition_class: ProjectTransition
                                              })
  end
end
