# coding: utf-8
class InvalidProject < StandardError; end
class SuccessfulProject < StandardError; end
class ProjectsController < ApplicationController

  after_filter :verify_authorized, except: %i[show index video video_embed embed embed_panel about_mobile]
  after_filter :redirect_user_back_after_login, only: %i[index show]
  before_action :authorize_and_build_resources, only: %i[edit]

  has_scope :pg_search, :by_category_id
  has_scope :recent, :expiring, :successful, :in_funding, :recommended, :not_expired, type: :boolean

  helper_method :project_comments_canonical_url, :resource, :collection

  respond_to :html
  respond_to :json, only: [:index, :show, :update]

  before_action :referral_it!

  def index
    respond_to do |format|
      format.html do
        return render_index_for_xhr_request if request.xhr?
      end
      format.atom do
        return render layout: false, locals: {projects: projects}
      end
      format.rss { redirect_to projects_path(format: :atom), :status => :moved_permanently }
    end
  end

  def new
    @project = Project.new user: current_user
    authorize @project
    @project.rewards.build
  end

  def create
    @project = Project.new
    @project.attributes = permitted_params.merge(
      user: current_user,
      origin: Origin.process_hash(referral))
    authorize @project
    if @project.save
      redirect_to insights_project_path(@project)
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
    resource_action :send_to_analysis, :analysis_success
  end

  def publish
    authorize resource
  end

  def validate_publish
    authorize resource
    Project.transaction do
      raise InvalidProject unless resource.push_to_online
      raise SuccessfulProject
    end
  rescue InvalidProject
    flash.now[:notice] = t("projects.push_to_online_error")
    build_dependencies
    render template: 'projects/edit'
  rescue SuccessfulProject
    redirect_to publish_project_path(resource)
  end

  def push_to_online
    authorize resource
    resource_action :push_to_online
  end

  def insights
    authorize resource, :update?
  end

  def update
    authorize resource

    #need to check this before setting new attributes
    should_validate = should_use_validate

    resource.localized.attributes = permitted_params
    #can't use localized for fee
    if permitted_params[:service_fee]
      resource.service_fee = permitted_params[:service_fee]
    end

    should_show_modal = resource.mode == 'flex' && resource.online_days_changed?


    if resource.save(validate: should_validate)
      flash[:notice] = t('project.update.success')
    else
      flash[:notice] = t('project.update.failed')
      build_dependencies
      return render :edit
    end

    if should_show_modal
      redirect_to insights_project_path(@project, show_modal: true)
    elsif params[:anchor]
      redirect_to edit_project_path(@project, anchor: params[:anchor])
    else
      redirect_to edit_project_path(@project, anchor: 'home')
    end
  end

  def show
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
    @post ||= resource.posts.where(id: params[:project_post_id].to_i).first if params[:project_post_id].present?
  end

  def video
    project = Project.new(video_url: params[:url])
    render json: project.video.to_json
  rescue VideoInfo::UrlError
    render json: nil
  end

  # TODO: remove when flex goes public
  def push_to_flex
    authorize resource
    resource.build_flexible_project
    resource.state = 'draft'
    resource.online_days = nil
    resource.expires_at = nil
    resource.save!
    resource.project_transitions.destroy_all
    redirect_to :back 
  end

  def embed
    resource
    render partial: 'card', layout: 'embed', locals: {embed_link: true, ref: (params[:ref] || 'ctrse_embed')}
  end

  def embed_panel
    resource
    render partial: 'project_embed'
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

    resource.build_account unless resource.account
  end

  def resource_action action_name, success_redirect=nil
    if resource.send(action_name)
      if resource.origin.nil? && referral.present?
        resource.update_attribute(
          :origin_id, Origin.process_hash(referral).try(:id))
      end

      flash[:notice] = t("projects.#{action_name.to_s}")
      if success_redirect
        redirect_to edit_project_path(@project, anchor: success_redirect)
      else
        redirect_to insights_project_path(@project)
      end
    else
      flash.now[:notice] = t("projects.#{action_name.to_s}_error")
      build_dependencies
      render :edit
    end
  end

  def render_index_for_xhr_request
    render partial: 'projects/card',
      collection: projects,
      layout: false,
      locals: {ref: "explore", wrapper_class: 'w-col w-col-4 u-marginbottom-20'}
  end

  def projects
    page = params[:page] || 1
    @projects ||= apply_scopes(Project.visible.order_status).
      most_recent_first.
      includes(:project_total, :user, :category).
      page(page).per(18)
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
