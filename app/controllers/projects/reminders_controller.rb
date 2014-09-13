class Projects::RemindersController < ApplicationController
  before_filter :authenticate_user!

  def create
    unless current_user.has_valid_contribution_for_project?(params[:id]) && project.user_already_in_reminder?(current_user.id)
      reminder_at = project.expires_at - 48.hours
      ReminderProjectWorker.perform_at(reminder_at, current_user.id, project.id)
    end
    flash[:notice] = t('projects.reminder.ok')
    redirect_to project_by_slug_path(project.permalink)
  end

  def destroy
    project.notifications.where(template_name: 'reminder', user_id: current_user.id).destroy_all
    project.delete_from_reminder_queue(current_user.id)

    redirect_to project_by_slug_path(project.permalink)
  end


  protected

  def project
    @project ||= Project.find params[:id]
  end
end
