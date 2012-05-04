# coding: utf-8
class UsersController < ApplicationController
  load_and_authorize_resource except: :update_attribute_on_the_spot
  inherit_resources
  actions :show, :update
  can_edit_on_the_spot
  before_filter :can_update_on_the_spot?, :only => :update_attribute_on_the_spot
  respond_to :json, :only => [:backs, :projects, :request_refund]
  def show
    show!{
      return redirect_to(user_path(@user.primary)) if @user.primary
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
      @credits = @user.backs.can_refund.within_refund_deadline.all
    }
  end

  def update
    update! do 
      flash[:notice] = t('users.current_user_fields.updated')
      return redirect_to user_path(@user, :anchor => 'settings')
    end
  end

  def projects
    @user = User.find(params[:id])
    @projects = @user.projects.order("updated_at DESC")
    @projects = @projects.visible unless @user == current_user
    @projects = @projects.page(params[:page]).per(10)
    render :json => @projects
  end

  def credits
    @user = User.find(params[:id])
    @credits = @user.backs.can_refund.within_refund_deadline.all
    render :json => @credits
  end

  def request_refund
    back = Backer.find(params[:back_id])
    begin
      refund = Credits::Refund.new(back, current_user)
      refund.make_request!
      status = refund.message
    rescue Exception => e
      status = e.message
    end

    render :json => {:status => status}
  end

  private
  def can_update_on_the_spot?
    user_fields = ["email", "name", "bio", "newsletter", "project_updates"]
    notification_fields = ["dismissed"]
    def render_error; render :text => t('require_permission'), :status => 422; end
    return render_error unless current_user
    klass, field, id = params[:id].split('__')
    return render_error unless klass == 'user' or klass == 'notification'
    if klass == 'user'
      return render_error unless user_fields.include? field
      user = User.find id
      return render_error unless current_user.id == user.id or current_user.admin
    elsif klass == 'notification'
      return render_error unless notification_fields.include? field
      notification = Notification.find id
      return render_error unless current_user.id == notification.user.id
    end
  end
end
