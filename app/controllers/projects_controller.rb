# coding: utf-8
class ProjectsController < ApplicationController
  after_filter :verify_authorized, except: %i[index video video_embed embed embed_panel]
  inherit_resources
  has_scope :pg_search, :by_category_id, :near_of
  has_scope :recent, :expiring, :successful, :in_funding, :recommended, :not_expired, type: :boolean

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
          return render partial: 'project', collection: @projects, layout: false
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
    create! { project_by_slug_path(@project.permalink) }
  end

  def destroy
    authorize resource
    destroy!
  end

  def send_to_analysis
    authorize resource
    resource.send_to_analysis
    if referal_link.present?
      resource.update_attribute :referal_link, referal_link
    end
    flash[:notice] = t('projects.send_to_analysis')
    redirect_to project_by_slug_path(@project.permalink)
  end

  def update
    authorize resource
    update! do |format|
      format.html do
        if resource.errors.present?
          flash[:alert] = resource.errors.full_messages.to_sentence
        else
          flash[:notice] = t('project.update.success')
        end

        redirect_to project_by_slug_path(@project.reload.permalink, anchor: 'edit')
      end
    end
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

  def embed_panel
    @title = resource.name
    render layout: false
  end

  protected

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end

  def resource
    @project ||= (params[:permalink].present? ? Project.by_permalink(params[:permalink]).first! : Project.find(params[:id]))
  end

  def use_catarse_boostrap
    action_name == "new" || action_name == "create" ? 'catarse_bootstrap' : 'application'
  end
end
