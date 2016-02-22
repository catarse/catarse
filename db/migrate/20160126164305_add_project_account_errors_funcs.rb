class AddProjectAccountErrorsFuncs < ActiveRecord::Migration
  def up
    execute <<-SQL
DROP VIEW "1".project_accounts;
CREATE OR REPLACE VIEW "1".project_accounts AS
    SELECT
        pa.project_id,
        p.user_id,
        b.name as bank_name,
        b.code as bank_code,
        pa.agency,
        pa.agency_digit,
        pa.account,
        pa.account_digit,
        pa.account_type,
        pa.owner_name,
        pa.owner_document,
        pa.state_inscription,
        pa.address_street,
        pa.address_number,
        pa.address_complement,
        pa.address_neighbourhood,
        pa.address_city,
        pa.address_state,
        pa.address_zip_code,
        pa.phone_number,
        (
            SELECT pae.reason FROM public.project_account_errors pae
            WHERE NOT pae.solved AND pae.project_account_id = pa.id ORDER BY pae.id DESC LIMIT 1
        ) as error_reason,
        (
            SELECT bt.state FROM "1".balance_transfers bt
            WHERE bt.project_id = p.id ORDER BY bt.id DESC LIMIT 1
        ) as transfer_state
    FROM public.project_accounts pa
        JOIN public.banks b ON b.id = pa.bank_id
        JOIN public.projects p ON p.id = pa.project_id
    WHERE public.is_owner_or_admin(p.user_id);

GRANT SELECT ON "1".project_accounts TO admin, web_user;
GRANT SELECT ON public.project_account_errors TO admin, web_user;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".project_accounts;
CREATE OR REPLACE VIEW "1".project_accounts AS
    SELECT
        pa.project_id,
        p.user_id,
        b.name as bank_name,
        b.code as bank_code,
        pa.agency,
        pa.agency_digit,
        pa.account,
        pa.account_digit,
        pa.account_type,
        pa.owner_name,
        pa.owner_document,
        pa.state_inscription,
        pa.address_street,
        pa.address_number,
        pa.address_complement,
        pa.address_neighbourhood,
        pa.address_city,
        pa.address_state,
        pa.address_zip_code,
        pa.phone_number,
        null::text as error_reason
    FROM public.project_accounts pa
        JOIN public.banks b ON b.id = pa.bank_id
        JOIN public.projects p ON p.id = pa.project_id
    WHERE public.is_owner_or_admin(p.user_id);

GRANT SELECT ON "1".project_accounts TO admin, web_user;
    SQL

  end
end
