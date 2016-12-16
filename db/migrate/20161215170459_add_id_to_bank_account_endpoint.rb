class AddIdToBankAccountEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".bank_accounts AS
    SELECT ba.user_id,
    b.name AS bank_name,
    b.code AS bank_code,
    ba.account,
    ba.account_digit,
    ba.agency,
    ba.agency_digit,
    ba.owner_name,
    ba.owner_document,
    ba.created_at,
    ba.updated_at,
    ba.id as bank_account_id,
    ba.bank_id as bank_id
   FROM bank_accounts ba
     JOIN banks b ON b.id = ba.bank_id
  WHERE is_owner_or_admin(ba.user_id);
    SQL
  end
end
