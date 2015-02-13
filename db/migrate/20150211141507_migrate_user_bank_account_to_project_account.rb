class MigrateUserBankAccountToProjectAccount < ActiveRecord::Migration
  def change
    execute "
    INSERT INTO project_accounts
    (user_id, project_id, bank_id, full_name, email, cpf, state_inscription, address_zip_code, address_state, address_neighbourhood, address_city, address_complement, address_number, address_street, phone_number, agency_digit, agency, account_digit, account,owner_document, owner_name, created_at, updated_at)
    SELECT
      u.id, p.id, bank_id, COALESCE(full_name, u.name), email, cpf, state_inscription, address_zip_code, address_state, address_neighbourhood, address_city, address_complement, address_number, address_street, phone_number, agency_digit, agency, account_digit, account,owner_document, owner_name, p.created_at, p.updated_at
    FROM
      projects p JOIN users u on u.id = p.user_id JOIN bank_accounts ba on ba.user_id = u.id
    WHERE
      ba.bank_id IS NOT NULL AND cpf IS NOT NULL AND agency_digit IS NOT NULL AND phone_number IS NOT NULL;
    "
  end
end
