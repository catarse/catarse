class Admin::ProjectsController < Admin::BaseController
  menu I18n.t("admin.projects.index.menu") => Rails.application.routes.url_helpers.admin_projects_path

  has_scope :by_id, :pg_search, :user_name_contains, :with_state, :by_online_date, :by_expires_at, :by_category_id, :by_goal
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
    order = params[:order_by].blank? ? 'created_at' : params[:order_by].split(' ')[0]
    scope= apply_scopes(end_of_association_chain).without_state('deleted').sort_by{|p| p.send(order)}
    scope = scope.reverse if !params[:order_by].blank? && (params[:order_by].split(' ')[1] == 'DESC')
    @projects ||= Kaminari.paginate_array(scope).page(params[:page])
  end
end
