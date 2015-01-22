class CleanBanks < ActiveRecord::Migration
  def change
    execute "
    UPDATE bank_accounts SET bank_id = 131 WHERE bank_id IN (70, 73);
    UPDATE bank_accounts SET bank_id = 23 WHERE bank_id IN (19, 21);
    UPDATE bank_accounts SET bank_id = 127 WHERE bank_id = 128;
    DELETE FROM banks WHERE id IN (70, 73, 19, 21, 128);
    "
  end
end
