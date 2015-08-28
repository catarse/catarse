module Project::StateMachineHandler
  extend ActiveSupport::Concern

  included do
    #NOTE: state machine things
    state_machine :state, initial: :draft do
      state :draft, value: 'draft'
      state :rejected, value: 'rejected'

      #validations starting in in_analysis
      state :in_analysis, :approved, :online, :successful, :waiting_funds, :failed do
        validates_presence_of :about_html, :headline, :goal, :online_days, :budget, :city
        validates_presence_of :uploaded_image, if: ->(project) { project.video_thumbnail.blank? }
        validate do
          [:uploaded_image, :about_html, :name].each do |attr|
            self.user.errors.add_on_blank(attr)
          end
          self.user.errors.each {|error, error_message| self.errors.add('user.' + error.to_s, error_message)}
          self.errors['rewards.size'] << "Deve haver pelo menos uma recompensa" if self.rewards.size == 0
          self.errors['account.agency_size'] << "Agência deve ter pelo menos 4 dígitos" if self.account && self.account.agency.size < 4
        end
      end

      #validations starting in approved
      state :approved, :online, :successful, :waiting_funds, :failed do
        validates_presence_of :video_url,
          if: ->(project) { (project.goal || 0) >= CatarseSettings[:minimum_goal_for_video].to_i }
      end

      #validations starting in online
      state :online, :successful, :waiting_funds, :failed do
        validates_presence_of :account, message: 'Dados Bancários não podem ficar em branco'
        validate do
          [:email, :address_street, :address_number, :address_city, :address_state, :address_zip_code, :phone_number, :bank, :agency, :account, :account_digit, :owner_name, :owner_document, :account_type].each do |attr|
            self.account.errors.add_on_blank(attr) if self.account.present?
          end
          self.account.errors.each {|error, error_message| self.errors.add('project_account.' + error.to_s, error_message)} if self.account.present?
        end
      end
      state :deleted, value: 'deleted'

      event :push_to_draft do
        transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
      end

      event :push_to_trash do
        transition [:draft, :rejected, :in_analysis] => :deleted
      end

      event :send_to_analysis do
        transition draft: :in_analysis
      end

      event :reject do
        transition in_analysis: :rejected
      end

      event :approve do
        transition in_analysis: :approved
      end

      event :push_to_online do
        transition approved: :online
      end

      event :finish do
        transition online: :failed,             if: ->(project) {
          project.should_fail? && !project.in_time_to_wait?
        }

        transition online: :waiting_funds,      if: ->(project) {
          project.expired?
        }

        transition waiting_funds: :waiting_funds,      if: ->(project) {
          project.in_time_to_wait?
        }

        transition waiting_funds: :successful,  if: ->(project) {
          project.reached_goal?
        }

        transition waiting_funds: :failed,      if: ->(project) {
          project.should_fail?
        }

      end

      after_transition do |project, transition|
        project.notify_observers :"from_#{transition.from}_to_#{transition.to}"
      end

      after_transition any => [:failed, :successful] do |project, transition|
        project.notify_observers :sync_with_mailchimp
      end

      after_transition any => :draft do |project, transition|
        project.update_attributes({ sent_to_draft_at: DateTime.current })
      end

      after_transition any => :rejected do |project, transition|
        project.update_attributes({ rejected_at: DateTime.current })
      end

      after_transition [:draft, :rejected] => :deleted do |project, transition|
        project.update_attributes({ permalink: "deleted_project_#{project.id}"})
      end
    end
  end
end

