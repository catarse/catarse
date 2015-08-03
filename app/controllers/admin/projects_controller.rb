class Admin::ProjectsController < Admin::BaseController
  layout 'catarse_bootstrap'

  has_scope :by_user_email, :by_id, :pg_search, :user_name_contains, :with_state, :by_category_id, :order_by
  has_scope :between_created_at, :between_expires_at, :between_online_date, :between_updated_at, :goal_between, using: [ :start_at, :ends_at ]

  before_filter do
    @total_projects = Project.count(:all)
  end

  [:approve, :reject, :push_to_draft, :push_to_trash, :push_to_online].each do |name|
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
  def permitted_params
    params.require(:project).permit(resource.attribute_names.map(&:to_sym))
  end

  def collection
    @scoped_projects = apply_scopes(Project).without_state('deleted')
    @projects = @scoped_projects.page(params[:page])
  end
end
