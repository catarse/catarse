class AdjustBankAccountsEndpoint < ActiveRecord::Migration
    def up
    execute <<-SQL
DROP VIEW "1".bank_accounts;
CREATE OR REPlACE VIEW "1".bank_accounts AS
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
    ba.updated_at
   FROM public.bank_accounts ba
     JOIN public.banks b ON b.id = ba.bank_id
  WHERE public.is_owner_or_admin(ba.user_id);

GRANT SELECT ON "1".bank_accounts TO admin, web_user;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".bank_accounts;
CREATE VIEW "1".bank_accounts AS
 WITH p_accs AS (
         SELECT p_1.user_id,
            max(pa_1.id) AS last_id
           FROM (public.project_accounts pa_1
             JOIN public.projects p_1 ON ((pa_1.project_id = p_1.id)))
          WHERE (public.successful_at(p_1.*) IS NOT NULL)
          GROUP BY p_1.user_id
        )
 SELECT pac.user_id,
    b.name AS bank_name,
    b.code AS bank_code,
    pa.account,
    pa.account_digit,
    pa.account_type,
    pa.agency,
    pa.agency_digit,
    pa.owner_name,
    pa.owner_document,
    pa.created_at,
    pa.updated_at
   FROM (((p_accs pac
     JOIN public.project_accounts pa ON ((pa.id = pac.last_id)))
     JOIN public.projects p ON ((pa.project_id = p.id)))
     LEFT JOIN public.banks b ON ((b.id = pa.bank_id)))
  WHERE public.is_owner_or_admin(pac.user_id);

GRANT SELECT ON "1".bank_accounts TO admin, web_user;
    SQL
  end
end
