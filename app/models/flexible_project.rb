# frozen_string_literal: true

class FlexibleProject < Project
  FINAL_LAP_INTERVAL = 7
  include Project::BaseValidator

  validates_numericality_of :online_days, less_than_or_equal_to: 365, greater_than_or_equal_to: 1,
                                          if: ->(p) { p.online_days.present? && (p.online_days_was.nil? || p.online_days_was <= 365) }

  scope :without_expiration, -> { where(expires_at: nil) }
  scope :with_expiring_rewards, -> { without_expiration.with_state(:online).where('EXISTS(SELECT true from rewards r WHERE r.project_id = projects.id AND r.deliver_at < (current_timestamp + \'1 month\'::interval))') }
  # delegate reusable methods from state_machine
  delegate :push_to_online, :finish, :push_to_draft,
           :push_to_trash, :reject, to: :state_machine

  def self.sti_name
    'flex'
  end

  # instace of a flexible project state machine
  def state_machine
    @state_machine ||= FlexProjectMachine.new(self, {
                                                transition_class: ProjectTransition
                                              })
  end

  def announce_expiration
    if expires_at.nil?
      update_attribute :expires_at, FINAL_LAP_INTERVAL.days.from_now.end_of_day
    end
  end

  def update_expires_at
    return unless online_days.present? && online_at.present?
    self.expires_at = ((state_was == 'online' ? Time.current : online_at.in_time_zone) + online_days.days).end_of_day
  end

  def max_deadline
    online_at + 365.days
  end

  def expired?
    pluck_from_database('is_expired')
  end
end
