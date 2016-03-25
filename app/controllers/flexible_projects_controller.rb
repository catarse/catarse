#@TODO: this controller is total for legacy dashboard support
# we will drop this soon when dashboard goes to API :)
class InvalidProject < StandardError; end
class SuccessfulProject < StandardError; end
class FlexibleProjectsController < ApplicationController
  after_filter :verify_authorized
  respond_to :html

  def self.parent_prefixes
    %w(application projects)
  end

  def publish
    authorize flexible_project
    render 'publish', project: resource
  end

  def validate_publish
    authorize flexible_project
    Project.transaction do
      raise InvalidProject unless flexible_project.push_to_online
      raise SuccessfulProject
    end
  rescue InvalidProject
    flash.now[:notice] = t("projects.push_to_online_error")
    build_dependencies
    render template: 'projects/edit'
  rescue SuccessfulProject
    redirect_to publish_flexible_project_path(flexible_project)
  end

  def push_to_online
    authorize flexible_project
    if flexible_project.push_to_online
      flash[:notice] = t("projects.push_to_online")
      redirect_to insights_project_path(resource, online_success: true)
    else
      flash.now[:notice] = t("projects.push_to_online_error")
      build_dependencies
      render template: 'projects/edit'
    end
  end

  def finish
    authorize flexible_project
    if flexible_project.announce_expiration
      flash[:notice] = t("projects.announce_expiration")
      redirect_to insights_project_path(resource)
    else
      flash.now[:notice] = t("projects.announce_expiration_error")
      redirect_to insights_project_path(resource)
    end
  end

  protected

  def flexible_project
    @flexible_project ||= FlexibleProject.find params[:id]
  end

  def resource
    @project ||= flexible_project.project
  end

  def build_dependencies
    @posts_count = resource.posts.count(:all)
    @user = resource.user
    @user.links.build
    @post =  (params[:project_post_id].present? ? resource.posts.where(id: params[:project_post_id]).first : resource.posts.build)
    @rewards = resource.rewards.rank(:row_order)
    @rewards = resource.rewards.build unless @rewards.present?

    resource.build_account unless resource.account
  end

end
