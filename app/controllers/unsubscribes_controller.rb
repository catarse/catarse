class UnsubscribesController < ApplicationController
  inherit_resources
  belongs_to :user

  def create
    params[:user][:unsubscribes_attributes].each_value do |subscription|
      if subscription[:subscribed] == '1' && !subscription[:id].nil? #change from unsubscribed to subscribed
        parent.unsubscribes.where(project_id: subscription[:project_id]).destroy_all
      elsif subscription[:subscribed] == '0' && subscription[:id].nil? #change from subscribed to unsubscribed
        parent.unsubscribes.create!(project_id: subscription[:project_id])
      end
    end
    flash[:notice] = t('users.current_user_fields.updated')
    return redirect_to user_path(parent, anchor: 'unsubscribes')
  end

end
