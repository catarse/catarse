class Admin::ProjectsController < Admin::BaseController
  add_to_menu "admin.projects.index.menu", :admin_projects_path

  has_scope :by_id, :pg_search, :user_name_contains, :with_state, :by_online_date, :by_expires_at, :by_updated_at, :by_category_id, :by_goal, :order_by
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true

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

    redirect_to admin_projects_path
  end

  protected
  def collection
    @projects = apply_scopes(end_of_association_chain).with_project_totals.without_state('deleted').page(params[:page])
  end
end
