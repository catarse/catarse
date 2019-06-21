class ProjectReportExport < ActiveRecord::Base
  REPORT_TYPE_LIST = [
    'SubscriptionMonthlyReportForProjectOwner',
    'SubscriptionReportForProjectOwner'
  ]
  belongs_to :project

  validates :project, :report_type, :state, presence: true
  validates :report_type, inclusion: { in: REPORT_TYPE_LIST }

  after_commit :start_worker, on: :create

  def start_worker
    ProjectReportExportWorker.perform_async(id)
  end

  def fetch_report
    _kclass = report_type.constantize
    csv = _kclass.project_id(resource.project.common_id).to_csv
  end
end
