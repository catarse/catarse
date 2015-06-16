class PendingRefundsController < ApplicationController
  helper_method :resource
  respond_to :html

  def self.policy_class
    BankAccountPolicy
  end

  def show
    authorize resource, :update?
  end

  def edit
    authorize resource, :update?
  end

  def update
    authorize resource, :update?
    resource.update_attributes(permitted_params)
    resource.save

    respond_with(resource, location: pending_refund_path)
  end

  def permitted_params
    params.require(:bank_account).permit(policy(resource).permitted_attributes)
  end

  def resource
    @bank_account ||= (current_user.bank_account || current_user.build_bank_account)
  end
end
