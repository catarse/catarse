# frozen_string_literal: true

class ProjectReportExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'export_report'

  def perform(id)
    resource = ProjectReportExport.find(id)
    resource.fetch_report
  end
end
