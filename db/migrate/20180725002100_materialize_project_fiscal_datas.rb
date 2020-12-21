class MaterializeProjectFiscalDatas < ActiveRecord::Migration[4.2]
    def up
        execute <<-SQL
        CREATE INDEX idx_balance_transactions_eventname_projectid_zcreatedat on  balance_transactions(event_name,project_id,zone_timestamp(created_at));

        CREATE MATERIALIZED VIEW "project_fiscal_datas_matview" AS
            with q as (
                select row_number() OVER (PARTITION BY project_id,fiscal_date,fiscal_year order by project_pledged_amount) as rn,
                    project_id,user_id,mode,fiscal_date,fiscal_year,project_pledged_amount,
                    service_fee,irrf,balance,total_gateway_fee,pj_pledget_by_month,pf_pledget_by_month
                from project_fiscal_datas
            )
            select project_id,user_id,mode,fiscal_date,fiscal_year,project_pledged_amount,
                service_fee,irrf,balance,total_gateway_fee,pj_pledget_by_month,pf_pledget_by_month
            from q
            where rn=1
        WITH NO DATA;

        CREATE UNIQUE INDEX idx_project_fiscal_datas ON project_fiscal_datas_matview(project_id, fiscal_date);

        CREATE OR REPLACE VIEW "1"."project_fiscal_ids" AS
            SELECT pfd.project_id,
                array_agg(pfd.fiscal_date ORDER BY pfd.fiscal_date) AS debit_notes,
                array_agg(DISTINCT pfd.fiscal_year ORDER BY pfd.fiscal_year) FILTER (WHERE ((pfd.mode <> 'sub'::text) OR ((pfd.fiscal_year)::double precision < date_part('year'::text, now())))) AS informs
            FROM project_fiscal_datas_matview pfd
            WHERE is_owner_or_admin(pfd.user_id)
            GROUP BY pfd.project_id;
    SQL
    end

    def down
      execute <<-SQL
        CREATE OR REPLACE VIEW "1"."project_fiscal_ids" AS
            SELECT pfd.project_id,
                array_agg(pfd.fiscal_date ORDER BY pfd.fiscal_date) AS debit_notes,
                array_agg(DISTINCT pfd.fiscal_year ORDER BY pfd.fiscal_year) FILTER (WHERE ((pfd.mode <> 'sub'::text) OR ((pfd.fiscal_year)::double precision < date_part('year'::text, now())))) AS informs
            FROM project_fiscal_datas pfd
            WHERE is_owner_or_admin(pfd.user_id)
            GROUP BY pfd.project_id;
        DROP INDEX idx_balance_transactions_eventname_projectid_zcreatedat;
        DROP MATERIALIZED VIEW "project_fiscal_datas_matview";
      SQL
    end
  end
