# coding: utf-8
class ProjectAccountsController < ApplicationController
  inherit_resources
  actions :update, :create

  def create
    @account = ProjectAccount.new params[:project_account]
    authorize @account
    if @account.save
      redirect_to edit_project_path(@account.project, anchor: 'user_settings')
    else
      redirect_to edit_project_path(@account.project, anchor: 'user_settings')
    end
  end

  def update
    authorize resource
    resource.attributes = permitted_params[:project_account]

    if resource.save
      flash[:notice] = t('users.current_user_fields.updated')
      redirect_to edit_project_path(@account.project, anchor: 'user_settings')
    else
      flash.now[:notice] = @account.errors.full_messages.to_sentence
      render :edit
    end
  end

  private

  def resource
    @account ||= ProjectAccount.find(params[:id])
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end

end
