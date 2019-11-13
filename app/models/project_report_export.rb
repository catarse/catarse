# coding: utf-8
class ProjectReportExport < ActiveRecord::Base

  REPORT_TYPE_LIST = %w[SubscriptionMonthlyReportForProjectOwner SubscriptionReportForProjectOwner]
  REPORT_TYPE_EXT_LIST = %w[csv xls]

  mount_uploader :output, ReportUploader

  belongs_to :project

  validates :project, :report_type_ext, :report_type, presence: true
  validates :report_type, inclusion: { in: REPORT_TYPE_LIST }
  validates :report_type_ext, inclusion: { in: REPORT_TYPE_EXT_LIST }

  after_commit :start_worker, on: :create

  def start_worker
    return unless state.eql?('pending')
    ProjectReportExportWorker.perform_async(id)
  end

  def fetch_report
    return if state.eql?('done')
    data = report_method_call
    data = Excelinator.csv_to_xls(data) if report_type_ext == 'xls'
    write_data_and_upload(data)
    begin
      Notification.notify(:project_report_exports, project.user, { project_report_exports_id: id })
    rescue
    end
  end

  def content_type
    case report_type_ext
    when 'csv'
      'application/csv'
    when 'xls'
      'application/vnd.ms-excel'
    else
    end
  end

  def report_filename_locale
    "#{I18n.t("projects.subscriptions.report_type.#{report_type}")}_#{created_at.to_time.to_i}.#{report_type_ext}"
  end

  def report_name_locale
    "#{I18n.t("projects.subscriptions.report_type.#{report_type}")}"
  end

  private

  def report_name
    "#{report_type}_#{created_at.to_time.to_i}"
  end


  def write_data_and_upload(data)
    file = Tempfile.new([report_name, '.', report_type_ext].join(''))
    begin
      file.write(data.force_encoding("UTF-8"))
      file.rewind
      self.output = file
      self.state = 'done'
      self.save
    ensure
      file.close
      file.unlink
    end
  end

  def report_class
    report_type.constantize
  end

  def report_method_call
    case report_type
    when 'SubscriptionReportForProjectOwner', 'SubscriptionMonthlyReportForProjectOwner'
      report_class.project_id(project.common_id).to_csv
    else
    end
  end
end
