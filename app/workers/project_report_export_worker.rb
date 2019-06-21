# frozen_string_literal: true

class ProjectReportExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'export_report'

  def perform(id)
    resource = ProjectReportExport.find(id)
    #TODO:
    # upload csv file
    # upload xls file
    # save output url (or maybe generate download url with id)
  end
end
