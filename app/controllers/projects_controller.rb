# coding: utf-8
class ProjectsController < ApplicationController
  after_filter :verify_authorized, except: %i[index video video_embed embed embed_panel about_mobile]
  inherit_resources
  has_scope :pg_search, :by_category_id, :near_of
  has_scope :recent, :expiring, :successful, :in_funding, :recommended, :not_expired, type: :boolean
  before_filter :detect_mobile_browsers, only: [:show]

  respond_to :html
  respond_to :json, only: [:index, :show, :update]

  def index
    index! do |format|
      format.html do
        if request.xhr?
          @projects = apply_scopes(Project.visible.order_status)
            .most_recent_first
            .includes(:project_total, :user, :category)
            .page(params[:page]).per(6)

          return render partial: 'projects/card',
            collection: @projects,
            layout: false,
            locals: {ref: "explore", wrapper_class: 'w-col w-col-4 u-marginbottom-20'}
        else
          @title = t("site.title")

          @recommends = ProjectsForHome.recommends.includes(:project_total)
          @projects_near = Project.with_state('online').near_of(current_user.address_state).order("random()").limit(3).includes(:project_total) if current_user
          @expiring = ProjectsForHome.expiring.includes(:project_total)
          @recent   = ProjectsForHome.recents.includes(:project_total)
        end
      end
    end
  end

  def new
    @project = Project.new user: current_user
    authorize @project
    @title = t('projects.new.title')
    @project.rewards.build
  end

  def create
    @project = Project.new params[:project].merge(user: current_user)
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
    @user = resource.user

    if resource.send_to_analysis
      if referal_link.present?
        resource.update_attribute :referal_link, referal_link
      end
      flash[:notice] = t('projects.send_to_analysis')
      redirect_to edit_project_path(@project, anchor: 'home')
    else
      flash.now[:notice] = t('projects.send_to_analysis_error')
      edit
      render :edit
    end
  end

  def publish
    authorize resource

    if resource.push_to_online
      flash[:notice] = t('projects.put_online')
      redirect_to edit_project_path(@project, anchor: 'home')
    else
      flash.now[:notice] = t('projects.put_online_error')
      edit
      render :edit
    end
  end

  def update
    authorize resource
    resource.attributes = permitted_params[:project]
    @user = resource.user

    if resource.save(validate: should_use_validate)
      flash[:notice] = t('project.update.success')
    else
      flash[:notice] = t('project.update.failed')
      edit
      return render :edit
    end

    if params[:anchor]
      redirect_to edit_project_path(@project, anchor: params[:anchor])
    else
      redirect_to edit_project_path(@project, anchor: 'home')
    end
  end

  def edit
    authorize resource
    @posts_count = resource.posts.count(:all)
    @user = resource.user
    @user.build_bank_account unless @user.bank_account.present?
    @user.links.build
    @post =  resource.posts.build
    @budget = resource.budgets.build
  end

  def fb_comments_link
    "#{request.base_url}/#{request.path.split('/').last}"
  end

  def show
    @title = resource.name
    authorize @project
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
    @posts_count = resource.posts.count(:all)
    @post = resource.posts.where(id: params[:project_post_id]).first if params[:project_post_id].present?
  end

  def video
    project = Project.new(video_url: params[:url])
    render json: project.video.to_json
  rescue VideoInfo::UrlError
    render json: nil
  end

  %w(embed video_embed).each do |method_name|
    define_method method_name do
      @title = resource.name
      render layout: 'embed'
    end
  end

  def about_mobile
    resource
  end

  def embed_panel
    @title = resource.name
    render layout: false
  end

  protected

  def should_use_validate
    (resource.online? || resource.failed? || resource.successful? || permitted_params[:project][:permalink].present? ? false : true)
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end

  def resource
    @project ||= (params[:permalink].present? ? Project.by_permalink(params[:permalink]).first! : Project.find(params[:id]))
  end

  def use_catarse_boostrap
    ['index', "edit", "new", "create", "show", "about_mobile", 'send_to_analysis', 'publish', 'update'].include?(action_name) ? 'catarse_bootstrap' : 'application'
  end
end
