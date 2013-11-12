class Admin::ProjectsController < Admin::BaseController
  add_to_menu "admin.projects.index.menu", :admin_projects_path

  has_scope :by_user_email, :by_id, :pg_search, :user_name_contains, :with_state, :by_category_id, :order_by
  has_scope [:between_created_at, :between_expires_at, :between_online_date, :between_updated_at, :goal_between], using: [ :start_at, :ends_at ], allow_blank: true

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
