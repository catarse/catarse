# frozen_string_literal: true

class Admin::BalanceTransactionsController < Admin::BaseController
  before_action :authenticate_user!
  before_action :ensure_balance_admin_role
  respond_to :json

  def transfer_balance
    begin
      perform_balance_transfer

      render json: { success: I18n.t("admin.balance_transactions.transfer_success") }, status: :created
    rescue => exception
      render json: { errors: [exception.message] }, status: :unprocessable_entity
    end
  end

  private

  def ensure_balance_admin_role
    raise Pundit::NotAuthorizedError unless AdminBalancePolicy.new(current_user, nil).access?
  end

  def perform_balance_transfer
    from_user = User.find(transfer_balance_params['from_user_id'])
    to_user = User.find(transfer_balance_params['to_user_id'])
    amount = transfer_balance_params['amount'].to_f

    BalanceTransaction.insert_balance_transfer_between_users(from_user, to_user, amount)
  end

  def transfer_balance_params
    params.require(:balance_transaction).permit(:from_user_id, :to_user_id, :amount)
  end

end
