class Admin::Reports::BackerReportsController < Admin::Reports::BaseController
  def end_of_association_chain
    super.where(project_id: params[:project_id])
  end
end

