class FixProjectFiscalDataTblRefresh < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.project_fiscal_data_tbl_refresh()
      RETURNS integer
      LANGUAGE plpgsql
      AS $function$
              DECLARE
                  b_count integer;
              BEGIN
                  insert into project_fiscal_data_tbl (
                      project_id, user_id, mode, fiscal_date, fiscal_year,
                      project_pledged_amount, service_fee, irrf, balance, total_gateway_fee,
                      pj_pledged_by_month, pf_pledged_by_month,
                      project_info, user_info, user_address,
                      balance_transfer_id, subscription_payment_uuids, payment_ids, total_antifraud_cost
                  )
                  select project_id, user_id, mode, fiscal_date, fiscal_year,
                      project_pledged_amount, service_fee, irrf, balance, total_gateway_fee,
                      pj_pledged_by_month, pf_pledged_by_month,
                      project_info, user_info, user_address,
                      balance_transfer_id, subscription_payment_uuids, payment_ids, total_antifraud_cost
                  from public.project_fiscal_data_tbl_refresh_supportview r
                  where not exists (
                      select 1
                      from public.project_fiscal_data_tbl t
                      where t.project_id=r.project_id and t.fiscal_date=r.fiscal_date
                  )
                  and r.project_id<>90320
                  and (r.total_payments>0)
                  and (r.mode='sub' or zone_timestamp(r.transferred_at)::date>='20190101');

                  GET DIAGNOSTICS b_count = ROW_COUNT;
                  RAISE NOTICE 'project_fiscal_data_tbl_refresh inserted % new rows', b_count;
                  RETURN b_count;
              END;
              $function$
      ;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.project_fiscal_data_tbl_refresh()
      RETURNS integer
      LANGUAGE plpgsql
      AS $function$
              DECLARE
                  b_count integer;
              BEGIN
                  insert into project_fiscal_data_tbl (
                      project_id, user_id, mode, fiscal_date, fiscal_year,
                      project_pledged_amount, service_fee, irrf, balance, total_gateway_fee,
                      pj_pledged_by_month, pf_pledged_by_month,
                      project_info, user_info, user_address,
                      balance_transfer_id, subscription_payment_uuids, payment_ids
                  )
                  select project_id, user_id, mode, fiscal_date, fiscal_year,
                      project_pledged_amount, service_fee, irrf, balance, total_gateway_fee,
                      pj_pledged_by_month, pf_pledged_by_month,
                      project_info, user_info, user_address,
                      balance_transfer_id, subscription_payment_uuids, payment_ids
                  from public.project_fiscal_data_tbl_refresh_supportview r
                  where not exists (
                      select 1
                      from public.project_fiscal_data_tbl t
                      where t.project_id=r.project_id and t.fiscal_date=r.fiscal_date
                  )
                  and r.project_id<>90320
                  and (r.total_payments>0)
                  and (r.mode='sub' or zone_timestamp(r.transferred_at)::date>='20190101');

                  GET DIAGNOSTICS b_count = ROW_COUNT;
                  RAISE NOTICE 'project_fiscal_data_tbl_refresh inserted % new rows', b_count;
                  RETURN b_count;
              END;
              $function$
      ;
    SQL
  end
end
