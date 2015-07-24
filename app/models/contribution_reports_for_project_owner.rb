class ContributionReportsForProjectOwner < ActiveRecord::Base
  acts_as_copy_target

  belongs_to :payment

  scope :project_id, -> (project_id) { where(project_id: project_id) }
  scope :reward_id, -> (reward_id) { where(reward_id: reward_id) }
  scope :state, -> (state) { where(state: state) }
  scope :waiting_payment, -> { where(waiting_payment: true) }
  scope :project_owner_id, -> (project_owner_id) { where(project_owner_id: project_owner_id) }

  def self.report
    report_sql = ""
    I18n.t('contribution_report_to_project_owner').keys[0..-2].each{
      |column| report_sql << "#{column} AS \"#{I18n.t("contribution_report_to_project_owner.#{column}")}\","
    }

    self.select(%Q{
        #{report_sql}
        CASE WHEN anonymous='t' THEN '#{I18n.t('yes')}'
            WHEN anonymous='f' THEN '#{I18n.t('no')}'
        END as "#{I18n.t('contribution_report_to_project_owner.anonymous')}"
      })
  end
end
