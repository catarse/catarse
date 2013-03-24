class Adm::FinancialsController < Adm::BaseController
  inherit_resources
  defaults  resource_class: Project, collection_name: 'projects', instance_name: 'project'
  menu I18n.t("adm.financials.index.menu") => Rails.application.routes.url_helpers.adm_financials_path
  has_scope :by_permalink, :name_contains, :user_name_contains, :financial, :by_state, :by_progress
  has_scope :between_expires_at, using: [ :start_at, :ends_at ], allow_blank: true
    
  actions :index

  def collection
    @search = apply_scopes(Project).includes(:user)
    @projects = @search.order("CASE state WHEN 'successful' THEN 1 WHEN 'waiting_funds' THEN 2 ELSE 3 END, expires_at::date").page(params[:page])
  end
end
