class Adm::ProjectsController < Adm::BaseController
  menu I18n.t("adm.projects.index.menu") => Rails.application.routes.url_helpers.adm_projects_path

  has_scope :by_id, :pg_search, :user_name_contains, :with_state
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :order_table, default: 'created_at'

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

  def destroy
    @project = Project.find params[:id]
    if @project.can_push_to_trash?
      @project.push_to_trash!
    end

    redirect_to adm_projects_path
  end

  def collection
    @projects = apply_scopes(end_of_association_chain).without_state('deleted').page(params[:page])
  end
end
