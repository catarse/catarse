class Adm::ProjectsController < Adm::BaseController
  menu I18n.t("adm.projects.index.menu") => Rails.application.routes.url_helpers.adm_projects_path

  has_scope :by_id, :pg_search, :user_name_contains, :order_table

  before_filter do
    @total_projects = Project.count
  end

  [:approve, :reject, :push_to_draft].each do |name|
    define_method name do
      @project = Project.find params[:id]
      @project.send("#{name.to_s}!")
      redirect_to :back
    end
  end

  def collection
    @search = apply_scopes(Project)
    @projects = @search.order('created_at DESC').page(params[:page]) unless current_scopes.include?(:order_table)
  end
end
