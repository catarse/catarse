class AddBankAccountsEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".bank_accounts AS
    WITH p_accs AS (
        SELECT
            p.user_id,
            max(pa.id) as last_id
        FROM public.project_accounts pa
        JOIN public.projects p ON pa.project_id = p.id
        WHERE p.successful_at IS NOT NULL
        GROUP BY p.user_id
    )
    SELECT
        pac.user_id,
        b.name as bank_name,
        b.code as bank_code,
        pa.account,
        pa.account_digit,
        pa.account_type,
        pa.agency,
        pa.agency_digit,
        pa.owner_name,
        pa.owner_document,
        pa.created_at,
        pa.updated_at
    FROM p_accs pac
    JOIN project_accounts pa ON pa.id = pac.last_id
    JOIN public.projects p ON pa.project_id = p.id
    LEFT JOIN public.banks b ON b.id = pa.bank_id
    WHERE public.is_owner_or_admin(pac.user_id);

GRANT SELECT ON "1".bank_accounts TO admin, web_user;
GRANT SELECT ON public.project_accounts TO admin, web_user;
GRANT SELECT ON public.banks TO admin, web_user;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".bank_accounts;
REVOKE SELECT ON public.project_accounts FROM admin, web_user;
REVOKE SELECT ON public.banks FROM admin, web_user;
    SQL
  end
end
