class Adm::FinancialsController < Adm::BaseController
  inherit_resources
  defaults  resource_class: Project, collection_name: 'projects', instance_name: 'project' 
  menu I18n.t("adm.financials.index.menu") => Rails.application.routes.url_helpers.adm_financials_path
  actions :index

  def collection
    @search = end_of_association_chain.search(params[:search])
    @projects = @search.order("created_at DESC").page(params[:page])
  end
end
