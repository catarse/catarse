class Projects::RemindersController < ApplicationController
  before_filter :authenticate_user!

  def create
    unless current_user.has_valid_contribution_for_project?(params[:id])
      reminder_at = project.expires_at - 48.hours
      project.notify_once(:reminder, current_user, project, {deliver_at: reminder_at})
    end

    flash[:notice] = t('projects.reminder.ok')
    redirect_to project_by_slug_path(project.permalink)
  end

  def destroy
    project.delete_from_reminder_queue(current_user.id)
    redirect_to project_by_slug_path(project.permalink)
  end

  protected

  def project
    @project ||= Project.find params[:id]
  end
end
