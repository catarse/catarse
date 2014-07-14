class UnsubscribesController < ApplicationController
  inherit_resources
  belongs_to :user

  def create
    drop_and_create_subscriptions

    flash[:notice] = t('users.current_user_fields.updated')
    return redirect_to user_path(parent, anchor: 'unsubscribes')
  end

  protected

  def drop_and_create_subscriptions
    params[:user][:unsubscribes_attributes].each_value do |subscription|
      project_id = subscription[:project_id]
      subscribed = subscription[:subscribed].to_i

      #change from unsubscribed to subscribed
      if subscribed && !subscription[:id].nil?
        user_unsubscribes.drop_all_for_project(project_id)
      #change from subscribed to unsubscribed
      elsif subscribed && subscription[:id].nil?
        user_unsubscribes.create!(project_id: subscription[:project_id])
      end
    end
  end

  def user_unsubscribes
    @unsubscribes ||= parent.unsubscribes
  end


end
