class MigrateBankCodeToBanks < ActiveRecord::Migration
  def up
    execute <<-SQL
      update bank_accounts SET bank_id = (select b.id from banks b where split_part(bank_accounts.name, ' ', 1) = b.code);
      ALTER TABLE bank_accounts ALTER COLUMN bank_id SET NOT NULL;
    SQL
    remove_column :bank_accounts, :name
  end

  def down
    change_column_null :bank_accounts, :bank_id, true
    add_column :bank_accounts, :name
  end
end
