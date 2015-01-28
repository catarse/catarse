# coding: utf-8
class UsersController < ApplicationController
  after_filter :verify_authorized, except: %i[reactivate]
  inherit_resources
  defaults finder: :find_active!
  actions :show, :update, :update_password, :unsubscribe_notifications, :credits, :destroy, :edit
  respond_to :json, only: [:contributions, :projects]

  def destroy
    authorize resource
    resource.deactivate
    sign_out(current_user) if current_user == resource
    flash[:notice] = t('users.current_user_fields.deactivate_notice', name: resource.name)
    redirect_to root_path
  end

  def unsubscribe_notifications
    authorize resource
    redirect_to user_path(current_user, anchor: 'unsubscribes')
  end

  def credits
    authorize resource
    redirect_to user_path(current_user, anchor: 'credits')
  end

  def settings
    authorize resource
    redirect_to user_path(current_user, anchor: 'settings')
  end

  def show
    authorize resource
    show!{
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
      @credits = @user.contributions.can_refund
      @subscribed_to_posts = @user.posts_subscription
      @unsubscribes = @user.project_unsubscribes
      @credit_cards = @user.credit_cards
      build_bank_account
    }
  end

  def reactivate
    user = params[:token].present? && User.find_by(reactivate_token: params[:token])
    if user
      user.reactivate
      sign_in user
      flash[:notice] = t('users.reactivated')
    else
      flash[:error] = t('users.failed_reactivation')
    end
    redirect_to root_path
  end

  def edit
    authorize resource
    @unsubscribes = @user.project_unsubscribes
    @subscribed_to_posts = @user.posts_subscription
    resource.links.build
  end

  def update
    authorize resource
    drop_and_create_subscriptions
    update_reminders
    resource.category_followers.clear
    update! do |success,failure|
      success.html do
        flash[:notice] = t('users.current_user_fields.updated')
        redirect_to edit_user_path(@user, anchor: params[:anchor])
      end
      failure.html do
        flash.now[:notice] = @user.errors.full_messages.to_sentence
        render :edit
      end
    end

  end

  def update_password
    authorize resource
    if @user.update_with_password(params[:user])
      flash[:notice] = t('users.current_user_fields.updated')
    else
      flash[:error] = @user.errors.full_messages.to_sentence
    end
    return redirect_to user_path(@user, anchor: 'settings')
  end

  private
  def update_reminders
    @user.projects_in_reminder.each do |project|
      unless params[:user][:reminders] && params[:user][:reminders].find {|p| p['project_id'] == project.id.to_s}
        project.delete_from_reminder_queue(@user.id)
      end
    end
  end

  def drop_and_create_subscriptions
    #unsubscribe to all projects
    if params[:subscribed].nil?
      @user.unsubscribes.create!(project_id: nil)
    else
      @user.unsubscribes.drop_all_for_project(nil)
    end
    if params[:unsubscribes]
      params[:unsubscribes].each do |subscription|
        project_id = subscription[0].to_i
        #change from unsubscribed to subscribed
        if subscription[1].present?
          @user.unsubscribes.drop_all_for_project(project_id)
        #change from subscribed to unsubscribed
        else
          @user.unsubscribes.create!(project_id: project_id)
        end
      end
    end
  end

  def build_bank_account
    @user.build_bank_account unless @user.bank_account
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end

  def use_catarse_boostrap
    ["show", "edit", "update"].include?(action_name) ? 'catarse_bootstrap' : 'application'
  end
end
