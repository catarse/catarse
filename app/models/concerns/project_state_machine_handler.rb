module ProjectStateMachineHandler
  extend ActiveSupport::Concern

  included do
    #NOTE: state machine things
    state_machine :state, initial: :draft do
      state :draft, value: 'draft'
      state :rejected, value: 'rejected'
      state :online, value: 'online'
      state :successful, value: 'successful'
      state :waiting_funds, value: 'waiting_funds'
      state :failed, value: 'failed'
      state :deleted, value: 'deleted'

      event :push_to_draft do
        transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
      end

      event :push_to_trash do
        transition [:draft, :rejected] => :deleted
      end

      event :reject do
        transition draft: :rejected
      end

      event :approve do
        transition draft: :online
      end

      event :finish do
        transition online: :failed,             if: ->(project) {
          project.should_fail? && !project.pending_backers_reached_the_goal?
        }

        transition online: :waiting_funds,      if: ->(project) {
          project.expired? && project.pending_backers_reached_the_goal?
        }

        transition waiting_funds: :successful,  if: ->(project) {
          project.reached_goal? && !project.in_time_to_wait?
        }

        transition waiting_funds: :failed,      if: ->(project) {
          project.should_fail? && !project.in_time_to_wait?
        }

        transition waiting_funds: :waiting_funds,      if: ->(project) {
          project.should_fail? && project.in_time_to_wait?
        }
      end

      after_transition do |project, transition|
        project.notify_observers :"from_#{transition.from}_to_#{transition.to}"
      end
      after_transition draft: :online do |project, transition|
        project.update_attributes({ online_date: DateTime.now })
      end
      after_transition any => [:failed, :successful] do |project, transition|
        project.notify_observers :sync_with_mailchimp
      end
      after_transition [:draft, :rejected] => :deleted do |project, transition|
        project.update_attributes({ permalink: "deleted_project_#{project.id}"})
      end
    end
  end
end

