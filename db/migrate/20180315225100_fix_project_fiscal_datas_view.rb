class FixProjectFiscalDatasView < ActiveRecord::Migration
    def up
        execute <<-SQL
DROP VIEW "1".project_fiscal_ids;
DROP VIEW public.project_fiscal_informs;
DROP VIEW public.project_fiscal_datas;

CREATE OR REPLACE VIEW public.project_fiscal_datas AS
select pr.id as project_id, pr.user_id, pr.mode,
--    pto.created_at as online_at,
    b.fiscal_date,
    extract(year from b.fiscal_date::date-'1 day'::interval)::integer as fiscal_year,
    round(b.project_pledged_amount,2) project_pledged_amount,
    round(b.service_fee,2) service_fee,
    round(b.irrf,2) irrf,
    round(b.balance,2) balance,
    round(tp.gateway_fee,2) as total_gateway_fee,
    tp.pj_pledget_by_month,
    tp.pf_pledget_by_month
from projects pr
join project_transitions pto on pto.project_id=pr.id and pto.to_state='online' and pto.created_at>'20170101'
join lateral (
    select to_char(zone_timestamp(btp.created_at),'YYYYMMDD') fiscal_date,
        btp.amount as project_pledged_amount,
        btfee.amount as service_fee,
        btirrf.amount as irrf,
        btp.amount+COALESCE(btfee.amount,0)+COALESCE(btirrf.amount,0) as balance
    from balance_transactions btp
    left join balance_transactions btfee on btfee.user_id=pr.user_id and btfee.project_id=pr.id and btfee.event_name='catarse_project_service_fee'
    left join balance_transactions btirrf on btirrf.user_id=pr.user_id and btirrf.project_id=pr.id and btfee.event_name='irrf_tax_project'
    where pr.mode<>'sub' and btp.project_id=pr.id and btp.event_name='successful_project_pledged'
    UNION
    select to_char(date_trunc('month',zone_timestamp(btp.created_at))+'1 month'::interval, 'YYYYMMDD') fiscal_date,
        sum(btp.amount) project_pledged_amount,
        sum(btfee.amount) service_fee,
        0 as irrf,
        sum(btp.amount+btfee.amount) balance
    from balance_transactions btp
    left join balance_transactions btfee on btfee.project_id=btp.project_id and btfee.subscription_payment_uuid=btp.subscription_payment_uuid and btfee.event_name='subscription_fee'
    where pr.mode='sub' and btp.project_id=pr.id and btp.event_name='subscription_payment' and zone_timestamp(btp.created_at)<date_trunc('month', CURRENT_TIMESTAMP)
    group by fiscal_date
) b on b.fiscal_date is not null
left join lateral (
    select round(sum(q.fee),2) as gateway_fee,
        array_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where q.is_pj) as pj_pledget_by_month,
        array_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where not q.is_pj) as pf_pledget_by_month
    from (
        (SELECT date_part('year', zone_timestamp(pa.paid_at)) AS "year",
            date_part('month', zone_timestamp(pa.paid_at)) AS "month",
            (pa.gateway_data->'customer'->> 'document_type') IS NOT NULL AND (pa.gateway_data->'customer'->>'document_type')='cnpj' AS is_pj,
            sum(pa.value) AS value,
            sum(pa.gateway_fee) as fee
        FROM payments pa
        JOIN contributions c ON c.id = pa.contribution_id
        WHERE pr.mode<>'sub' and c.project_id=pr.id AND pa.state = 'paid'
        GROUP BY 1,2,3 ORDER BY 1,2,3)
        UNION
        (SELECT date_part('year', zone_timestamp(ptp.created_at)) AS "year",
            date_part('month', zone_timestamp(ptp.created_at)) AS "month",
            (pa.gateway_general_data ->> 'customer_document_type') IS NOT NULL AND (pa.gateway_general_data ->> 'customer_document_type')='cnpj' AS is_pj,
            round(sum((pa.data ->> 'amount')::numeric / 100::numeric),2) AS value,
            round(sum( (CASE WHEN (pa.gateway_general_data ->> 'gateway_payment_method')='credit_card'
                        THEN COALESCE((pa.gateway_general_data->>'gateway_cost')::numeric,0)+COALESCE((pa.gateway_general_data->>'payable_total_fee')::numeric,0)
                        ELSE COALESCE((pa.gateway_general_data->>'gateway_cost'),(pa.gateway_general_data->>'payable_total_fee'))::numeric END
                ) / 100::numeric),2) AS fee
        FROM common_schema.catalog_payments pa
        JOIN common_schema.payment_status_transitions ptp ON ptp.catalog_payment_id = pa.id AND ptp.to_status = 'paid'::payment_service.payment_status
        WHERE pr.mode='sub' and pa.project_id=pr.common_id
          and zone_timestamp(ptp.created_at) BETWEEN b.fiscal_date::date-'1 month'::interval AND b.fiscal_date::date-'1 second'::interval
        GROUP BY 1,2,3 ORDER BY 1,2,3)
    ) q
) tp on true
where pr.state in ('online','successful');

CREATE OR REPLACE VIEW public.project_fiscal_informs AS
select project_id, user_id, mode, fiscal_year,
    max(fiscal_date) as fiscal_date,
    min(project_pledged_amount) project_pledged_amount,
    min(service_fee) service_fee,
    min(irrf) irrf,
    min(balance) balance,
    min(total_gateway_fee) total_gateway_fee,
    min(pj.pledget_by_month) as pj_pledget_by_month,
    min(pf.pledget_by_month) as pf_pledget_by_month
from public.project_fiscal_datas pfd
left join lateral (
    select array_agg(p ORDER BY p->>'year', p->>'month') pledget_by_month from unnest(pfd.pj_pledget_by_month) p where p is not null
) pj on true
left join lateral (
    select array_agg(p ORDER BY p->>'year', p->>'month') pledget_by_month from unnest(pfd.pf_pledget_by_month) p where p is not null
) pf on true
group by project_id, user_id, mode, fiscal_year;

CREATE OR REPLACE VIEW "1".project_fiscal_ids AS
select pfd.project_id,
    array_agg(fiscal_date ORDER BY fiscal_date) debit_notes,
    array_agg(distinct fiscal_year ORDER BY fiscal_year)FILTER(where pfd.mode<>'sub' or fiscal_year<extract(year from current_timestamp)) informs
from public.project_fiscal_datas pfd
where is_owner_or_admin(user_id)
group by pfd.project_id;

GRANT SELECT ON TABLE "1".project_fiscal_ids TO anonymous;
GRANT SELECT ON TABLE "1".project_fiscal_ids TO web_user;
GRANT SELECT ON TABLE "1".project_fiscal_ids TO admin;

        SQL
      end

    def down
      execute <<-SQL
CREATE OR REPLACE VIEW public.project_fiscal_datas AS
select pr.id as project_id, pr.user_id, pr.mode,
--    pto.created_at as online_at,
    b.fiscal_date,
    extract(year from b.fiscal_date::date-'1 day'::interval) as fiscal_year,
    round(b.project_pledged_amount,2) project_pledged_amount,
    round(b.service_fee,2) service_fee,
    round(b.irrf,2) irrf,
    round(b.balance,2) balance,
    round(tp.gateway_fee,2) as total_gateway_fee,
    tp.pj_pledget_by_month,
    tp.pf_pledget_by_month
from projects pr
join project_transitions pto on pto.project_id=pr.id and pto.to_state='online' and pto.created_at>'20170101'
join lateral (
    select to_char(zone_timestamp(btp.created_at),'YYYYMMDD') fiscal_date,
        btp.amount as project_pledged_amount,
        btfee.amount as service_fee,
        btirrf.amount as irrf,
        btp.amount+COALESCE(btfee.amount,0)+COALESCE(btirrf.amount,0) as balance
    from balance_transactions btp
    left join balance_transactions btfee on btfee.user_id=pr.user_id and btfee.project_id=pr.id and btfee.event_name='catarse_project_service_fee'
    left join balance_transactions btirrf on btirrf.user_id=pr.user_id and btirrf.project_id=pr.id and btfee.event_name='irrf_tax_project'
    where pr.mode<>'sub' and btp.project_id=pr.id and btp.event_name='successful_project_pledged'
    UNION
    select to_char(date_trunc('month',zone_timestamp(btp.created_at))+'1 month'::interval, 'YYYYMMDD') fiscal_date,
        sum(btp.amount) project_pledged_amount,
        sum(btfee.amount) service_fee,
        0 as irrf,
        sum(btp.amount+btfee.amount) balance
    from balance_transactions btp
    left join balance_transactions btfee on btfee.project_id=btp.project_id and btfee.subscription_payment_uuid=btp.subscription_payment_uuid and btfee.event_name='subscription_fee'
    where pr.mode='sub' and btp.project_id=pr.id and btp.event_name='subscription_payment' and zone_timestamp(btp.created_at)<date_trunc('month', CURRENT_TIMESTAMP)
    group by fiscal_date
) b on b.fiscal_date is not null
left join lateral (
    select round(sum(q.fee),2) as gateway_fee,
        array_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where q.is_pj) as pj_pledget_by_month,
        array_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where not q.is_pj) as pf_pledget_by_month
    from (
        (SELECT date_part('year', zone_timestamp(pa.paid_at)) AS "year",
            date_part('month', zone_timestamp(pa.paid_at)) AS "month",
            (pa.gateway_data->'customer'->> 'document_type') IS NOT NULL AND (pa.gateway_data->'customer'->>'document_type')='cnpj' AS is_pj,
            sum(pa.value) AS value,
            sum(pa.gateway_fee) as fee
        FROM payments pa
        JOIN contributions c ON c.id = pa.contribution_id
        WHERE pr.mode<>'sub' and c.project_id=pr.id AND pa.state = 'paid'
        GROUP BY 1,2,3 ORDER BY 1,2,3)
        UNION
        (SELECT date_part('year', zone_timestamp(ptp.created_at)) AS "year",
            date_part('month', zone_timestamp(ptp.created_at)) AS "month",
            (pa.gateway_general_data ->> 'customer_document_type') IS NOT NULL AND (pa.gateway_general_data ->> 'customer_document_type')='cnpj' AS is_pj,
            round(sum((pa.data ->> 'amount')::numeric / 100::numeric),2) AS value,
            round(sum((pa.gateway_general_data ->> 'payable_total_fee')::numeric / 100::numeric),2) AS fee
        FROM common_schema.catalog_payments pa
        JOIN common_schema.payment_status_transitions ptp ON ptp.catalog_payment_id = pa.id AND ptp.to_status = 'paid'::payment_service.payment_status
        WHERE pr.mode='sub' and pa.project_id=pr.common_id
        and zone_timestamp(ptp.created_at) BETWEEN b.fiscal_date::date-'1 month'::interval AND b.fiscal_date::date-'1 second'::interval
        GROUP BY 1,2,3 ORDER BY 1,2,3)
    ) q
) tp on true
where pr.state in ('online','successful');

CREATE OR REPLACE VIEW public.project_fiscal_informs AS
select project_id, user_id, mode, fiscal_year,
    max(fiscal_date) as fiscal_date,
    sum(project_pledged_amount) project_pledged_amount,
    sum(service_fee) service_fee,
    sum(irrf) irrf,
    sum(balance) balance,
    sum(total_gateway_fee) total_gateway_fee,
    array_agg(pj.pledget_by_month)FILTER(where pj.pledget_by_month is not null) pj_pledget_by_month,
    array_agg(pf.pledget_by_month)FILTER(where pf.pledget_by_month is not null) pf_pledget_by_month
from public.project_fiscal_datas pfd
left join lateral (
    select unnest(pj_pledget_by_month) pledget_by_month
) pj on true
left join lateral (
    select unnest(pf_pledget_by_month) pledget_by_month
) pf on true
group by project_id, user_id, mode, fiscal_year;

CREATE OR REPLACE VIEW "1".project_fiscal_ids AS
select pfd.project_id,
    array_agg(fiscal_date) debit_notes,
    array_agg(distinct fiscal_year)FILTER(where pfd.mode<>'sub' or fiscal_date::date<date_trunc('year',current_timestamp)) informs
from public.project_fiscal_datas pfd
where is_owner_or_admin(user_id)
group by pfd.project_id;

GRANT SELECT ON TABLE "1".project_fiscal_ids TO anonymous;
GRANT SELECT ON TABLE "1".project_fiscal_ids TO web_user;
GRANT SELECT ON TABLE "1".project_fiscal_ids TO admin;
    SQL
    end
  end
  