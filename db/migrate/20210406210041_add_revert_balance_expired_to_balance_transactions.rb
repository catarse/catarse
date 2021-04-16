class AddRevertBalanceExpiredToBalanceTransactions < ActiveRecord::Migration[6.1]
  def up
    execute %Q{
      create unique index idx_revert_balance_expired_evt_uniq on balance_transactions (event_name, balance_transaction_id) where event_name = 'revert_balance_expired';
    }
  end

  def down 
    execute %Q{
      drop index if exists idx_revert_balance_expired_evt_uniq;
    }
  end
end
