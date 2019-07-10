# coding: utf-8
# frozen_string_literal: true

class UsersController < ApplicationController
  after_filter :verify_authorized, except: %i[reactivate]
  after_filter :redirect_user_back_after_login, only: %i[show]
  inherit_resources
  defaults finder: :find_active!
  actions :show, :update, :unsubscribe_notifications, :destroy, :edit
  respond_to :json, only: %i[contributions projects]
  before_action :referral_it!, only: [:show]
  before_action :authenticate_user!, only: [:follow_fb_friends]

  def balance
    authorize resource, :update?
  end

  def follow_fb_friends
    authorize current_user, :update?
    if params[:follow_user_id] && current_user.followers.pluck(:user_id).include?(params[:follow_user_id].to_i)
      api = ApiWrapper.new current_user
      api.request('user_follows', {
                    body: { follow_id: params[:follow_user_id] }.to_json,
                    action: :post
                  }).run
    end
  end

  def destroy
    authorize resource
    resource.deactivate
    sign_out(current_user) if current_user == resource
    flash[:notice] = t('users.current_user_fields.deactivate_notice', name: resource.name)
    redirect_to root_path
  end

  def unsubscribe_notifications
    authorize resource
    redirect_to edit_user_path(current_user, anchor: 'notifications')
  end

  # TODO: Go back here and rethink this...
  def settings
    authorize resource
    redirect_to edit_user_path(current_user, anchor: 'settings')
  end

  def billing
    authorize resource
    redirect_to edit_user_path(current_user, anchor: 'settings')
  end

  def show
    authorize resource
    show! do
      @title = @user.display_name.to_s
      # @unsubscribes = @user.project_unsubscribes
      # @credit_cards = @user.credit_cards
      # build_bank_account
    end
  end

  def credit_cards
    authorize resource

    render json: current_user.credit_cards.to_json
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

  def new_password
    authorize resource

    if params[:password]
      @user.password = params[:password]
      if @user.save
        render json: { success: 'OK' }
      else
        render status: 400, json: { errors: @user.errors.full_messages }
      end
    else
      render status: 400, json: { errors: ['Missing parameter password'] }
    end
  end

  def edit
    authorize resource
    resource.links.build
    build_bank_account
  end

  def upload_image
    authorize resource, :update?
    params[:user] = {
      uploaded_image: params[:uploaded_image],
      cover_image: params[:cover_image]
    }

    if @user.update_without_password permitted_params
      @user.reload
      render status: 200, json: {
        uploaded_image: @user.uploaded_image.url(:thumb_avatar),
        cover_image: @user.cover_image.url(:base)
      }
    else
      render status: 400, json: { errors: @user.errors.full_messages }
    end
  end

  def update
    authorize resource

    if update_user
      # flash[:notice] = t('users.current_user_fields.updated')
      respond_to do |format|
        format.json { render json: { success: 'OK' } }
        format.html { redirect_to edit_user_path(@user, anchor: params[:anchor]) }
      end
    else
      respond_to do |format|
        format.json { render status: 400, json: { errors: @user.errors.messages.map { |e| e[1][0] }.uniq, errors_json: @user.errors.to_json } }
        format.html { redirect_to edit_user_path(@user, anchor: params[:anchor]) }
      end
    end
  end

  def ban
    authorize resource
    resource.update_column(:banned_at, DateTime.now)
    BlacklistDocument.find_or_create_by(number: @user.cpf) unless @user.cpf.nil?

    respond_to do |format|
      format.json { render json: { success: 'OK' } }
      format.html { redirect_to edit_user_path(@user) }
    end
  end

  private

  def update_user
    params[:user][:confirmed_email_at] = DateTime.now if params[:user].try(:[], :confirmed_email_at).present?
    @user.publishing_project = params[:user][:publishing_project].presence
    @user.publishing_user_about = params[:user][:publishing_user_about].presence
    @user.publishing_user_settings = params[:user][:publishing_user_settings].presence
    email_update?
    drop_and_create_subscriptions
    update_reminders
    update_category_followers

    if password_params_given?
      if @user.update_with_password permitted_params
        sign_in(@user, bypass: true)
      end
    else
      @user.update_without_password permitted_params
      @user.save
    end
  end

  def email_update?
    unless params[:user].try(:[], :email).present?
      params[:user][:email] = @user.email
    end
  end

  def category_followers_params_given?
    params.include?(:category_followers_form)
  end

  def password_params_given?
    permitted_params[:current_password].present? || permitted_params[:password].present?
  end

  def update_category_followers
    resource.category_followers.clear if category_followers_params_given?
  end

  def update_reminders
    if params[:user][:reminders]
      params[:user][:reminders].keys.each do |project_id|
        if params[:user][:reminders][:"#{project_id}"] == 'false'
          Project.find(project_id).delete_from_reminder_queue(@user.id)
          @user.reminders.where(project_id: project_id).destroy_all
        end
      end
    end
  end

  def drop_and_create_subscriptions
    params[:unsubscribes]&.each do |subscription|
      project_id = subscription[0].to_i

      puts "+++++++++++++++++++++++"
      puts subscription.inspect
      puts project_id
      puts "+++++++++++++++++++++++"
      # change from unsubscribed to subscribed
      if subscription[1] == '1'
        @user.unsubscribes.drop_all_for_project(project_id)
      # change from subscribed to unsubscribed
      else
        @user.unsubscribes.create!(project_id: project_id)
      end
    end
  end

  def resource
    @user ||= params[:id].present? ? User.find_active!(params[:id]) : User.with_permalink.find_by_permalink(request.subdomain)
  end

  def build_bank_account
    @user.build_bank_account unless @user.bank_account
  end

  def permitted_params
    params.require(:user).permit(policy(resource).permitted_attributes)
  end
end
