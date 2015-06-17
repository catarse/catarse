class BankAccountsController < ApplicationController
  helper_method :resource
  respond_to :html

  def new
    authorize resource, :update?
    redirect_to edit_bank_account_path(resource) unless resource.new_record?
  end

  def edit
    authorize resource, :update?
  end

  def resource
    @bank_account ||= find_bank_account
  end

  protected

  def find_bank_account
    (BankAccount.find(params[:id]) if params[:id]) ||
      current_user.bank_account ||
      current_user.build_bank_account
  end
end
