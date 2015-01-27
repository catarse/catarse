class UnsubscribesController < ApplicationController
  inherit_resources
  belongs_to :user

  def create
    drop_and_create_subscriptions

    flash[:notice] = t('users.current_user_fields.updated')
    return redirect_to edit_user_path(parent, anchor: 'notifications')
  end

  protected

  def drop_and_create_subscriptions
    #unsubscribe to all projects
    if params[:subscribed].nil?
      user_unsubscribes.create!(project_id: nil)
    else
      user_unsubscribes.drop_all_for_project(nil)
    end
    params[:unsubscribes].each do |subscription|
      project_id = subscription[0].to_i
      #change from unsubscribed to subscribed
      if subscription[1].present?
        user_unsubscribes.drop_all_for_project(project_id)
      #change from subscribed to unsubscribed
      else
        user_unsubscribes.create!(project_id: project_id)
      end
    end
  end

  def user_unsubscribes
    @unsubscribes ||= parent.unsubscribes
  end


end
