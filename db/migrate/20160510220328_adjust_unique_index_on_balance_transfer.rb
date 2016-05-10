class AdjustUniqueIndexOnBalanceTransfer < ActiveRecord::Migration
  def up
    execute %Q{
DROP INDEX index_balance_transfer_transitions_parent_most_recent;

CREATE UNIQUE INDEX index_balance_transfer_transitions_parent_most_recent ON balance_transfer_transitions USING btree (balance_transfer_id, most_recent) WHERE most_recent;
    }
  end

  def down
    execute %Q{
DROP INDEX index_balance_transfer_transitions_parent_most_recent;

CREATE UNIQUE INDEX index_balance_transfer_transitions_parent_most_recent ON balance_transfer_transitions USING btree (balance_transfer_id, most_recent);

    }
  end
end
