class Reports::BackerReportsForProjectOwnersController < Reports::BaseController
  before_filter :check_if_project_belongs_to_user

  def end_of_association_chain
    conditions = { project_id: params[:project_id] }

    conditions.merge!(reward_id: params[:reward_id]) if params[:reward_id].present?

    super.where(conditions)
  end

  def check_if_project_belongs_to_user
    can? :update, Project.find(params[:project_id])
  end
end
