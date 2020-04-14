class InsertBankAccountMetadataOnBalanceTransfers < ActiveRecord::Migration
  def up
    execute <<-SQL

    ALTER TABLE balance_transfers
    ADD metadata jsonb;
    
    SQL
  end

  def down
    execute <<-SQL
    
    ALTER TABLE balance_transfers
    DROP COLUMN metadata;

    SQL
  end
end
