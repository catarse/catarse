# coding: utf-8
class ProjectsController < ApplicationController
  load_and_authorize_resource only: [ :new, :create, :update, :destroy ]

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
          @recommends = if current_user && current_user.recommended_projects.present?
                            current_user.recommended_projects.limit(3)
                          else
                            ProjectsForHome.recommends
                          end

          @projects_near = Project.online.near_of(current_user.address_state).order("random()").limit(3) if current_user
          @expiring = ProjectsForHome.expiring
          @recent   = ProjectsForHome.recents
        end
      end
    end
  end

  def new
    new! do
      @title = t('projects.new.title')
      @project.rewards.build
    end
  end

  def create
    @project = current_user.projects.new(params[:project])

    create!(notice: t('projects.create.success')) do |success, failure|
      success.html{ return redirect_to project_by_slug_path(@project.permalink) }
    end
  end

  def update
    update! do |success, failure|
      success.html{ return redirect_to project_by_slug_path(@project.permalink, anchor: 'edit') }
      failure.html{ return redirect_to project_by_slug_path(@project.permalink, anchor: 'edit') }
    end
  end

  def show
    begin
      if params[:permalink].present?
        @project = Project.not_deleted_projects.by_permalink(params[:permalink]).last
      else
        return redirect_to project_by_slug_path(resource.permalink)
      end

      show! do
        @title = @project.name
        @rewards = @project.rewards.includes(:project).rank(:row_order).all
        fb_admins_add(@project.user.facebook_id) if @project.user.facebook_id
        @updates_count = @project.updates.count
        @update = @project.updates.where(id: params[:update_id]).first if params[:update_id].present?
      end
    rescue ActiveRecord::RecordNotFound
      return render_404
    end
  end

  def video
    project = Project.new(video_url: params[:url])
    if project.video
      render json: project.video.to_json
    else
      render json: {video_id: false}.to_json
    end
  end

  def check_slug
    valid = false
    valid = true if !Project.permalink_on_routes?(params[:permalink]) && !Project.by_permalink(params[:permalink]).present?
    render json: {available: valid}.to_json
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

  def resource
    @project ||= Project.not_deleted_projects.find params[:id]
  end
end
