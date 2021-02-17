# frozen_string_literal: true

class Admin::BalanceTransfersController < Admin::BaseController
  before_action :authenticate_user!
  before_action :ensure_balance_admin_role
  respond_to :json

  def update
    resource.update(transfer_params)
    render json: { updated: :ok }
  end

  def batch_approve
    batch_id = nil
    ActiveRecord::Base.transaction do
      pending_transfers.find_each do |resource|
        resource.transition_to!(:authorized, { authorized_by: current_user.id })
      end

      batch_id = Transfeera::BatchTransfer.create(authorized_transfers)
      authorized_transfers.update_all(:batch_id => batch_id)
      authorized_transfers.find_each do |resource|
        resource.transition_to!(:processing)
      end
    end

    render json: { transfer_ids: processing_transfers.pluck(&:id) }

  rescue StandardError => error_message
    Sentry.capture_exception(error_message)
    Transfeera::BatchTransfer.remove(batch_id) unless batch_id.nil?
    render json: { transfer_ids: [], error_message: error_message }, status: :unprocessable_entity
  end

  def batch_manual
    pending_transfers.find_each do |resource|
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

    render json: { transfer_ids: pending_transfers.pluck(&:id) }
  end

  def batch_reject
    pending_transfers.find_each do |resource|
      resource.transition_to!(
        :rejected,
        authorized_by: current_user.id,
        transfer_data: {
          bank_account: resource.user.bank_account.to_hash_with_bank
        }
      )
    end

    render json: { transfer_ids: pending_transfers.pluck(&:id) }
  end

  private

  def ensure_balance_admin_role
    raise Pundit::NotAuthorizedError unless AdminBalancePolicy.new(current_user, nil).access?
  end

  def resource
    @resource ||= BalanceTransfer.find params[:id]
  end

  def pending_transfers
    @pending_transfers ||= BalanceTransfer.pending.where(id: params[:transfer_ids])
  end

  def authorized_transfers
    @authorized_transfers ||= BalanceTransfer.authorized.where(id: params[:transfer_ids])
  end

  def processing_transfers
    @processing_transfers ||= BalanceTransfer.processing.where(id: params[:transfer_ids])
  end

  def transfer_params
    params.require(:balance_transfer).permit(:admin_notes)
  end

end
