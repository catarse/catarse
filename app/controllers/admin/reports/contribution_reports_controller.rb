class Admin::Reports::ContributionReportsController < Admin::BaseController
  include Concerns::Admin::ReportsHandler
  actions :index

  def end_of_association_chain
    super.where(project_id: params[:project_id])
  end
end

