# coding: utf-8
class ProjectsController < ApplicationController
  after_filter :verify_authorized, except: %i[index video video_embed embed embed_panel about_mobile]
  after_filter :redirect_user_back_after_login, only: %i[index show]
  before_action :authorize_and_build_resources, only: %i[edit show]

  inherit_resources
  has_scope :pg_search, :by_category_id, :near_of
  has_scope :recent, :expiring, :successful, :in_funding, :recommended, :not_expired, type: :boolean

  helper_method :project_comments_canonical_url

  respond_to :html
  respond_to :json, only: [:index, :show, :update]

  def index
    index! do |format|
      format.html do
        return render_index_for_xhr_request if request.xhr?
        projects_for_home
      end
    end
  end

  def new
    @project = Project.new user: current_user
    authorize @project
    @project.rewards.build
  end

  def create
    @project = Project.new params[:project].merge(user: current_user, referral_link: referral_link)
    authorize @project
    if @project.save
      redirect_to edit_project_path(@project, anchor: 'home')
    else
      render :new
    end
  end

  def destroy
    authorize resource
    destroy!
  end

  def send_to_analysis
    authorize resource
    resource_action :send_to_analysis
  end

  def publish
    authorize resource
    resource_action :push_to_online
  end

  def update
    authorize resource

    #need to check this before setting new attributes
    should_validate = should_use_validate

    resource.attributes = permitted_params

    if resource.save(validate: should_validate)
      flash[:notice] = t('project.update.success')
    else
      flash[:notice] = t('project.update.failed')
      build_dependencies
      return render :edit
    end

    if params[:anchor]
      redirect_to edit_project_path(@project, anchor: params[:anchor])
    else
      redirect_to edit_project_path(@project, anchor: 'home')
    end
  end

  def show
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
  end

  def video
    project = Project.new(video_url: params[:url])
    render json: project.video.to_json
  rescue VideoInfo::UrlError
    render json: nil
  end

  def embed
    resource
    render partial: 'card', layout: 'embed', locals: {embed_link: true}
  end

  def embed_panel
    resource
    render partial: 'project_embed'
  end

  def about_mobile
    resource
  end

  protected
  def authorize_and_build_resources
    authorize resource
    build_dependencies
  end

  def build_dependencies
    @posts_count = resource.posts.count(:all)
    @user = resource.user
    @user.links.build
    @post =  (params[:project_post_id].present? ? resource.posts.where(id: params[:project_post_id]).first : resource.posts.build)
    @rewards = @project.rewards.rank(:row_order)
    @rewards = @project.rewards.build unless @rewards.present?
    @budget = resource.budgets.build

    resource.build_account unless resource.account
  end

  def resource_action action_name
    if resource.send(action_name)
      if referral_link.present?
        resource.update_attribute :referral_link, referral_link
      end

      flash[:notice] = t("projects.#{action_name.to_s}")
      redirect_to edit_project_path(@project, anchor: 'home')
    else
      flash.now[:notice] = t("projects.#{action_name.to_s}_error")
      build_dependencies
      render :edit
    end
  end

  def render_index_for_xhr_request
    @projects = apply_scopes(Project.visible.order_status)
      .most_recent_first
      .includes(:project_total, :user, :category)
      .page(params[:page]).per(18)

    render partial: 'projects/card',
      collection: @projects,
      layout: false,
      locals: {ref: "explore", wrapper_class: 'w-col w-col-4 u-marginbottom-20'}
  end

  def projects_for_home
    @recommends = ProjectsForHome.recommends.includes(:project_total, :user)
    @projects_near = Project.with_state('online').near_of(current_user.address_state).order("random()").limit(3).includes(:project_total, :user) if current_user
    @expiring = ProjectsForHome.expiring.includes(:project_total, :user)
    @recent   = ProjectsForHome.recents.includes(:project_total, :user)
  end

  def should_use_validate
    resource.valid?
  end

  def permitted_params
    params.require(:project).permit(policy(resource).permitted_attributes)
  end

  def resource
    @project ||= (params[:permalink].present? ? Project.by_permalink(params[:permalink]).first! : Project.find(params[:id]))
  end

  def project_comments_canonical_url
    url = project_by_slug_url(resource.permalink, protocol: 'http', subdomain: 'www').split('/')
    url.delete_at(3) #remove language from url
    url.join('/')
  end
end
