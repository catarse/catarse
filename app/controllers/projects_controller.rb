# coding: utf-8
class ProjectsController < ApplicationController
  after_filter :verify_authorized, except: %i[index video video_embed embed embed_panel]
  inherit_resources
  has_scope :pg_search, :by_category_id, :near_of
  has_scope :recent, :expiring, :successful, :recommended, :not_expired, type: :boolean

  respond_to :html
  respond_to :json, only: [:index, :show, :update]

  def index
    index! do |format|
      format.html do
        if request.xhr?
          @projects = apply_scopes(Project).visible.order_for_search.includes(:project_total, :user, :category).page(params[:page]).per(6)
          return render partial: 'project', collection: @projects, layout: false
        else
          @title = t("site.title")
          if current_user && current_user.recommended_projects.present?
            @recommends = current_user.recommended_projects.limit(3)
          else
            @recommends = ProjectsForHome.recommends
          end

          @channel_projects = Project.from_channels([1]).order_for_search.limit(3)
          @projects_near = Project.with_state('online').near_of(current_user.address_state).order("random()").limit(3) if current_user
          @expiring = ProjectsForHome.expiring
          @recent   = ProjectsForHome.recents
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
    resource.send_to_analysis
    authorize @project
    flash[:notice] = t('projects.send_to_analysis')
    redirect_to project_by_slug_path(@project.permalink)
  end

  def update
    authorize resource
    update!(notice: t('projects.update.success')) { project_by_slug_path(@project.permalink, anchor: 'edit') }
  end

  def show
    @title = resource.name
    authorize @project
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
    @updates_count = resource.updates.count
    @update = resource.updates.where(id: params[:update_id]).first if params[:update_id].present?
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
end
