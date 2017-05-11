class BalanceTransaction < ActiveRecord::Base
  EVENT_NAMES = %w(
    catarse_contribution_fee
    project_contribution_confirmed_after_finished
    balance_transfer_project
    balance_transfer_request
    balance_transfer_error
    transfered_project_pledged
    successful_project_pledged
    catarse_project_service_fee
    irrf_tax_project )

  belongs_to :project
  belongs_to :contribution
  belongs_to :user

  validates :event_name, inclusion: { in: EVENT_NAMES }
  validates :amount, :event_name, :user_id, presence: true

  def self.insert_contribution_confirmed_after_project_finished(project_id, contribution_id)
    project = Project.find project_id
    contribution = Contribution.find contribution_id
    return unless project.successful?
    return unless contribution.confirmed?

    self.transaction do
      default_params = {
        contribution_id: contribution_id,
        project_id: project_id,
        user_id: project.user_id
      }

      create!(default_params.merge(
                event_name: 'project_contribution_confirmed_after_finished',
                amount: contribution.value))
      create!(default_params.merge(
                event_name: 'catarse_contribution_fee',
                amount: (contribution.value * contribution.project.service_fee) * -1))
    end
  end

  def self.insert_successful_project_transactions(project_id)
    project = Project.find project_id
    return unless project.successful?
    return unless project.project_transfer.present?
    self.transaction do
      default_params = { project_id: project_id, user_id: project.user_id }

      create!(default_params.merge(
                event_name: 'successful_project_pledged',
                amount: project.project_transfer.pledged))
      create!(default_params.merge(
                event_name: 'catarse_project_service_fee',
                amount: (project.project_transfer.catarse_fee * -1)))
      create!(default_params.merge(
                event_name: 'irrf_tax_project',
                amount: project.project_transfer.irrf_tax)) if project.project_transfer.irrf_tax > 0
    end
  end
end
