# coding: utf-8
class UsersController < ApplicationController
  load_and_authorize_resource new: [ :set_email ], except: [ :projects ]
  inherit_resources
  actions :show, :update, :unsubscribe_update, :request_refund, :set_email, :update_email
  respond_to :json, :only => [:backs, :projects, :request_refund]

  def show
    show!{
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
      @credits = @user.backs.can_refund.all
      @subscribed_to_updates = @user.updates_subscription
      @unsubscribes = @user.project_unsubscribes
    }
  end

  def set_email
    @user = current_user
  end

  def update_email
    update! do |success,failure|
      success.html do
        flash[:notice] = t('users.current_user_fields.updated')
        redirect_to (session[:return_to] || user_path(@user, :anchor => 'settings'))
        session[:return_to] = nil
        return
      end
      failure.html{ return render :set_email }
    end
  end

  def update
    update! do
      flash[:notice] = t('users.current_user_fields.updated')
      return redirect_to user_path(@user, :anchor => 'settings')
    end
  end

  def update_password
    @user = User.find(params[:id])
    if @user.update_with_password(params[:user])
      flash[:notice] = t('users.current_user_fields.updated')
    else
      flash[:error] = @user.errors.full_messages.to_sentence
    end
    return redirect_to user_path(@user, :anchor => 'settings')
  end

  def projects
    @user = User.find(params[:id])
    @projects = @user.projects.includes(:user, :category, :project_total).order("updated_at DESC")
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
