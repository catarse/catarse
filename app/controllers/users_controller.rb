# coding: utf-8
class UsersController < ApplicationController
  load_and_authorize_resource
  inherit_resources
  actions :show
  can_edit_on_the_spot
  before_filter :can_update_on_the_spot?, :only => :update_attribute_on_the_spot
  respond_to :json, :only => [:backs, :projects, :request_refund]
  def show
    show!{
      return redirect_to(user_path(@user.primary)) if @user.primary
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
      @credits = @user.backs.can_refund.within_refund_deadline.all

      # @backs = @user.backs.confirmed.order(:confirmed_at)
      # @backs = @backs.not_anonymous unless @user == current_user or (current_user and current_user.admin)
      # @backs = @backs.all
      # @projects = @user.projects.order("updated_at DESC")
      # @projects = @projects.visible unless @user == current_user
      # @projects = @projects.all
    }
  end

  def backs
    @user = User.find(params[:id])
    @backs = @user.backs.confirmed
    @backs = @backs.not_anonymous unless @user == current_user or (current_user and current_user.admin)
    @backs = @backs.order("confirmed_at DESC").page(params[:page]).per(10)
    render :json => @backs.to_json({:include_project => true, :include_reward => true})
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
    back = Backer.find(params[:id])
    if back.nil?
      status = 'not found'
    elsif not authorize!(:request_refund, back)
      status = I18n.t('credits.refund.cannot_refund')
    else
      begin
        back.refund!
        status = 'Pedido de estorno enviado'
      rescue Exception => e
        status = e.message
      end
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
