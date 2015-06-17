class BankAccountsController < ApplicationController
  after_action :verify_authorized
  helper_method :resource
  respond_to :html

  def new
    authorize resource
    redirect_to edit_bank_account_path(resource) unless resource.new_record?
  end

  def edit
    authorize resource
  end

  def show
    authorize resource
  end

  def update
    authorize resource
    resource.update_attributes(permitted_params)
    respond_with resource
  end

  def resource
    @bank_account ||= find_bank_account
  end

  protected

  def permitted_params
    params.require(:bank_account).permit(policy(resource).permitted_attributes)
  end

  def find_bank_account
    (BankAccount.find(params[:id]) if params[:id]) ||
      current_user.bank_account ||
      current_user.build_bank_account
  end
end
