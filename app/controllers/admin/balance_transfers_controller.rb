# frozen_string_literal: true

class Admin::BalanceTransfersController < Admin::BaseController
  before_filter :authenticate_user!
  before_action :ensure_balance_admin_role
  respond_to :json

  def update
    resource.update_attributes(transfer_params)
    render json: { updated: :ok }
  end

  def batch_approve
    collection.find_each do |resource|
      resource.transition_to!(:authorized, { authorized_by: current_user.id })
    end

    render json: { transfer_ids: collection.pluck(&:id) }
  end

  def batch_manual
    collection.find_each do |resource|
      BalanceTransfer.transaction do
        resource.transition_to!(
          :authorized, { authorized_by: current_user.id }
        )
        resource.transition_to!(:processing)
        resource.transition_to!(
          :transferred, {
            transfer_data: {
              bank_account: resource.user.bank_account.to_hash_with_bank,
              manual_transfer: true
            }
          }
        )
      end
    end

    render json: { transfer_ids: collection.pluck(&:id) }
  end

  def batch_reject
    collection.find_each do |resource|
      resource.transition_to!(
        :rejected,
        authorized_by: current_user.id,
        transfer_data: {
          bank_account: resource.user.bank_account.to_hash_with_bank
        }
      )
    end

    render json: { transfer_ids: collection.pluck(&:id) }
  end

  private

  def ensure_balance_admin_role
    raise Pundit::NotAuthorizedError unless AdminBalancePolicy.new(current_user, nil).access?
  end

  def resource
    @resource ||= BalanceTransfer.find params[:id]
  end

  def collection
    @collection ||= BalanceTransfer.pending.where(id: params[:transfer_ids])
  end

  def transfer_params
    params.require(:balance_transfer).permit(:admin_notes)
  end

end
