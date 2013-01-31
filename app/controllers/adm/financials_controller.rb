class Adm::FinancialsController < Adm::BaseController
  inherit_resources
  defaults  resource_class: Project, collection_name: 'projects', instance_name: 'project' 
  menu I18n.t("adm.financials.index.menu") => Rails.application.routes.url_helpers.adm_financials_path
  actions :index

  def collection
    @search = end_of_association_chain.
      where("expires_at > current_timestamp - '15 days'::interval").
      where("state in ('online', 'successful', 'waiting_funds')").includes(:project_total, :user).search(params[:search])
    @projects = @search.order("CASE state WHEN 'successful' THEN 1 WHEN 'waiting_funds' THEN 2 ELSE 3 END, expires_at::date").page(params[:page])
  end
end
