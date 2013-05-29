class UnsubscribesController < ApplicationController
  inherit_resources
  belongs_to :user

  def create
    params[:user][:unsubscribes_attributes].each_value do |u|
      u[:notification_type_id] = NotificationType.where(name: 'updates').last.id if u[:project_id].nil? #unsubscribe from all projects
      if u[:subscribed] == '1' && !u[:id].nil? #change from unsubscribed to subscribed
        parent.unsubscribes.where(project_id: u[:project_id], notification_type_id: u[:notification_type_id]).destroy_all
      elsif u[:subscribed] == '0' && u[:id].nil? #change from subscribed to unsubscribed
        parent.unsubscribes.create!(project_id: u[:project_id], notification_type_id: u[:notification_type_id])
      end
    end
    flash[:notice] = t('users.current_user_fields.updated')
    return redirect_to user_path(parent, anchor: 'unsubscribes')
  end

end
