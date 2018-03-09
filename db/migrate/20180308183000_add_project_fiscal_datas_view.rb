class AddProjectFiscalDatasView < ActiveRecord::Migration
    def up
        execute <<-SQL
CREATE OR REPLACE VIEW public.project_fiscal_datas AS
select btp.project_id, btp.user_id,
    round(btp.amount,2) as project_pledged_amount,
    round(btfee.amount,2) as service_fee,
    round(btirrf.amount,2) as irrf,
    round(btrefund.amount,2) as refund,
    round(btp.amount+COALESCE(btfee.amount,0)+COALESCE(btirrf.amount,0)+COALESCE(btrefund.amount,0),2) as balance,
    round(tp.gateway_fee,2) as total_gateway_fee,
    tp.pj_pledget_by_month,
    tp.pf_pledget_by_month
from projects pr
join balance_transactions btp on btp.project_id=pr.id and btp.event_name='successful_project_pledged' 
left join balance_transactions btfee on btfee.user_id=btp.user_id and btfee.project_id=btp.project_id and btfee.event_name='catarse_project_service_fee'
left join balance_transactions btirrf on btirrf.user_id=btp.user_id and btirrf.project_id=btp.project_id and btfee.event_name='irrf_tax_project'
left join balance_transactions btrefund on btrefund.user_id=btp.user_id and btrefund.project_id=btp.project_id and btrefund.event_name='refund_contributions'
left join lateral (
    with q as (
        SELECT date_part('year', zone_timestamp(pa.paid_at)) AS "year",
            date_part('month', zone_timestamp(pa.paid_at)) AS "month",
            (pa.gateway_data->'customer'->> 'document_type') IS NOT NULL AND (pa.gateway_data->'customer'->>'document_type')='cnpj' AS is_pj,
            sum(pa.value) AS value,
            sum(pa.gateway_fee) as fee
        FROM payments pa
        JOIN contributions c ON c.id = pa.contribution_id
        WHERE c.project_id=pr.id AND pa.state = 'paid'
        GROUP BY "year", "month", is_pj
        ORDER BY "year", "month", is_pj
    )
    select round(sum(fee),2) as gateway_fee,
        json_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where q.is_pj) as pj_pledget_by_month,
        json_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where not q.is_pj) as pf_pledget_by_month
    from q
) tp on true
where pr.mode<>'sub' and pr.state<>'rejected' and btrefund.id is null;

        SQL
      end

    def down
      execute <<-SQL
  DROP VIEW public.project_fiscal_datas;
      SQL
    end
  end
  