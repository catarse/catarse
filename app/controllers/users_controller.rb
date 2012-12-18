# coding: utf-8
class UsersController < ApplicationController
  load_and_authorize_resource except: [:update_attribute_on_the_spot, :projects]
  inherit_resources
  actions :show, :update, :unsubscribe_update
  respond_to :json, :only => [:backs, :projects, :request_refund]
  def show
    show!{
      return redirect_to(user_path(@user.primary)) if @user.primary
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
      @credits = @user.backs.can_refund.all
      @subscribed_to_updates = @user.updates_subscription
      @unsubscribes = @user.project_unsubscribes
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
    @credits = @user.backs.can_refund.order(:id).all
    render :json => @credits
  end

  def request_refund
    back = Backer.find(params[:back_id])
    begin
      if can? :request_refund, back
        refund = Credits::Refund.new(back, current_user)
        refund.make_request!
        status = refund.message
      end
    rescue Exception => e
      status = e.message
    end

    render :json => {:status => status, :credits => current_user.reload.display_credits}
  end
end
