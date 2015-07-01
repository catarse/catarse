class BankAccountsController < ApplicationController
  after_action :verify_authorized
  helper_method :resource, :user_decorator
  respond_to :html
  before_filter :authenticate_user!
  before_filter :need_pending_refunds, except: [:show]

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

  def create
    authorize resource
    resource.update_attributes(permitted_params)

    if resource.save
      redirect_to confirm_bank_account_path(resource)
    else
      render :edit
    end
  end

  def update
    authorize resource
    resource.update_attributes(permitted_params)
    respond_with(resource, location: confirm_bank_account_path(resource))
  end

  def request_refund
    authorize resource

    user.pending_refund_payments.each do |payment|
      payment.direct_refund
    end

    redirect_to bank_account_path(resource, refunded_amount: user_decorator.display_pending_refund_payments_amount)
  end

  def resource
    @bank_account ||= find_bank_account
  end

  def user_decorator
    user.decorator
  end

  protected

  def user
    @user ||= resource.user
  end

  def need_pending_refunds
    if !current_user.pending_refund_payments.present?
      redirect_to root_path unless current_user.admin?
    end
  end

  def permitted_params
    params.require(:bank_account).permit(policy(resource).permitted_attributes)
  end

  def find_bank_account
    params[:id].present? ? BankAccount.find(params[:id]) : (current_user.bank_account || current_user.build_bank_account)
  end
end
