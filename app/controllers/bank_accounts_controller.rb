class BankAccountsController < ApplicationController
  after_action :verify_authorized
  helper_method :resource
  respond_to :html
  before_filter :need_pending_refunds

  def new
    authorize resource
    if !resource.new_record?
      redirect_to edit_bank_account_path(resource)
    else
      render :edit
    end
  end

  def edit
    authorize resource
  end

  def show
    authorize resource
  end

  def confirm
    authorize resource
  end

  def update
    authorize resource
    resource.update_attributes(permitted_params)
    respond_with(resource, location: confirm_bank_account_path(resource))
  end

  def resource
    @bank_account ||= find_bank_account
  end

  protected

  def need_pending_refunds
    if !current_user.pending_refund_payments.present?
      redirect_to root_path unless current_user.admin?
    end
  end

  def permitted_params
    params.require(:bank_account).permit(policy(resource).permitted_attributes)
  end

  def find_bank_account
    (BankAccount.find(params[:id]) if params[:id]) ||
      current_user.bank_account ||
      current_user.build_bank_account
  end
end
