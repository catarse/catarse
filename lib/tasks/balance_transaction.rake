namespace :balance_transaction do
  desc 'expire balance transactions that can be expired'
  task expire_transactions: [:environment] do
    BalanceTransaction.where("balance_transactions.can_expire_on_balance").find_each do |transaction|
      Rails.logger.info("expiring balance transaction id #{transaction.id}")
      BalanceTransaction.insert_balance_expired(transaction.id)
    end
  end
end
