class UnsubscribesController < ApplicationController

  def index
    render :json => {:project_subscriptions => Unsubscribe.where('project_id IS NOT NULL', user_id: params[:user_id]).all }.to_json
  end

  def create
    @unsubscribe = Unsubscribe.where(user_id: params[:user_id], project_id: params[:project_id], notification_type_id: params[:notification_type_id])
    if @unsubscribe.empty?
      Unsubscribe.new(user_id: params[:user_id], project_id: params[:project_id], notification_type_id: params[:notification_type_id]).save!
    else
      Unsubscribe.destroy @unsubscribe
    end
    render :nothing => true
  end

 end
