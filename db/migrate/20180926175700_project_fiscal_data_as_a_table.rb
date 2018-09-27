class ProjectFiscalDataAsATable < ActiveRecord::Migration
    def up
        execute <<-SQL
        CREATE TABLE public.project_fiscal_data_tbl
        (
            project_id integer NOT NULL,
            user_id integer NOT NULL,
            mode text COLLATE pg_catalog."default" NOT NULL,
            fiscal_date text COLLATE pg_catalog."default" NOT NULL,
            fiscal_year integer NOT NULL,
            project_pledged_amount numeric NOT NULL,
            service_fee numeric NOT NULL,
            irrf numeric,
            balance numeric,
            total_gateway_fee numeric,
            pj_pledged_by_month json[],
            pf_pledged_by_month json[],
            project_info json NOT NULL,
            user_info json NOT NULL,
            user_address json
        );
        create unique index project_fiscal_data_tbl_idx on public.project_fiscal_data_tbl(project_id,fiscal_date)

        CREATE OR REPLACE FUNCTION public.project_fiscal_data_tbl_refresh()
        RETURNS void
            LANGUAGE 'sql'
            COST 100
            VOLATILE 
        AS $BODY$
            INSERT INTO public.project_fiscal_data_tbl
            SELECT pr.id as project_id, pr.user_id, pr.mode,
                to_char(b.fiscal_date,'YYYYMMDD') as fiscal_date,
                extract(year from b.fiscal_date-'1 day'::interval)::integer as fiscal_year,
                round(b.project_pledged_amount,2) project_pledged_amount,
                round(coalesce(b.service_fee,0),2) service_fee,
                round(b.irrf,2) irrf,
                round(b.balance,2) balance,
                round(tp.gateway_fee,2) as total_gateway_fee,
                tp.pj_pledged_by_month,
                tp.pf_pledged_by_month,
                to_json(pr) as project_info,
                to_json(u) as user_info,
                to_json(ad) as user_address
            from projects pr
            join users u on u.id=pr.user_id
            left join addresses ad on ad.id=u.address_id
            join lateral (
                select * from project_transitions pto
                where pto.project_id=pr.id and pto.to_state='online'
                order by created_at desc
                limit 1
            ) pto on pto.id is not null
            left join project_transitions pts on pts.project_id=pr.id and pts.to_state='successful'
            join lateral (
                select zone_timestamp(btp.created_at)::date fiscal_date,
                    btp.amount as project_pledged_amount,
                    btfee.amount as service_fee,
                    btirrf.amount as irrf,
                    btp.amount+COALESCE(btfee.amount,0)+COALESCE(btirrf.amount,0) as balance
                from balance_transactions btp
                left join balance_transactions btfee on btfee.user_id=pr.user_id and btfee.project_id=pr.id and btfee.event_name='catarseproject_info_service_fee'
                left join balance_transactions btirrf on btirrf.user_id=pr.user_id and btirrf.project_id=pr.id and btirrf.event_name='irrf_tax_project'
                where pr.mode<>'sub' and btp.project_id=pr.id and btp.event_name='successful_project_pledged'
                and zone_timestamp(btp.created_at)::date >= coalesce((select max(fiscal_date) from public.project_fiscal_data_tbl), '20160101')::date
                UNION
                select (date_trunc('month',zone_timestamp(btp.created_at))+'1 month'::interval)::date fiscal_date,
                    sum(btp.amount) project_pledged_amount,
                    sum(btfee.amount) service_fee,
                    0 as irrf,
                    sum(btp.amount+btfee.amount) balance
                from balance_transactions btp
                left join balance_transactions btfee on btfee.project_id=btp.project_id and btfee.subscription_payment_uuid=btp.subscription_payment_uuid and btfee.event_name='subscription_fee'
                where pr.mode='sub' and btp.project_id=pr.id and btp.event_name='subscription_payment' and zone_timestamp(btp.created_at)<date_trunc('month', CURRENT_TIMESTAMP)
                and (date_trunc('month',zone_timestamp(btp.created_at))+'1 month'::interval)::date >= coalesce((select max(fiscal_date) from public.project_fiscal_data_tbl), '20160101')::date
                group by fiscal_date
                order by fiscal_date
            ) b on b.fiscal_date is not null
            left join lateral (
                select round(sum(q.fee),2) as gateway_fee,
                    array_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where q.is_pj) as pj_pledged_by_month,
                    array_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where not q.is_pj) as pf_pledged_by_month
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
                    JOIN LATERAL (
                        select *
                        from common_schema.payment_status_transitions ptp
                        where ptp.catalog_payment_id = pa.id AND ptp.to_status = 'paid'::payment_service.payment_status
                        and zone_timestamp(ptp.created_at) BETWEEN b.fiscal_date::date-'1 month'::interval AND b.fiscal_date::date-'1 second'::interval
                        order by ptp.created_at desc limit 1
                    ) ptp on true
                    WHERE pr.mode='sub' and pa.project_id=pr.common_id and not exists ( --nao existe outra mudança de status no período depois do paid
                        select 1
                        from common_schema.payment_status_transitions ptf
                        where ptf.catalog_payment_id = pa.id AND ptf.created_at > ptp.created_at
                        and zone_timestamp(ptf.created_at) BETWEEN b.fiscal_date::date-'1 month'::interval AND b.fiscal_date::date-'1 second'::interval
                    )
                    GROUP BY 1,2,3 ORDER BY 1,2,3)
                ) q
            ) tp on true
            where (pr.state='online' or (pr.state='successful' and pts.created_at>'20170101'))
            and not exists (select 1 from project_fiscal_data_tbl t where t.project_id=pr.id and t.fiscal_date=to_char(b.fiscal_date,'YYYYMMDD'));
        $BODY$;

        CREATE OR REPLACE VIEW public.project_fiscal_informs_view AS
        select project_id, user_id, mode, fiscal_year,
            max(fiscal_date) as fiscal_date,
            sum(project_pledged_amount) project_pledged_amount,
            sum(service_fee) service_fee,
            sum(irrf) irrf,
            sum(balance) balance,
            sum(total_gateway_fee) total_gateway_fee,
            array_agg(pj.pledged_by_month)FILTER(where pj.pledged_by_month is not null) pj_pledged_by_month,
            array_agg(pf.pledged_by_month)FILTER(where pf.pledged_by_month is not null) pf_pledged_by_month,
            json_agg(project_info)->0 project_info,
            json_agg(user_info)->0 user_info,
            json_agg(user_address)->0 user_address
        from public.project_fiscal_data_tbl pfd
        left join lateral (
            select unnest(pj_pledged_by_month) pledged_by_month
        ) pj on true
        left join lateral (
            select unnest(pf_pledged_by_month) pledged_by_month
        ) pf on true
        group by project_id, user_id, mode, fiscal_year;


        CREATE OR REPLACE VIEW "1".project_fiscal_ids AS
        select pfd.project_id,
            array_agg(fiscal_date ORDER BY fiscal_date) debit_notes,
            array_agg(distinct fiscal_year ORDER BY fiscal_year)FILTER(where pfd.mode<>'sub' or fiscal_year<extract(year from current_timestamp)) informs
        from public.project_fiscal_data_tbl pfd
        where is_owner_or_admin(user_id)
        group by pfd.project_id;
        GRANT SELECT ON TABLE "1".project_fiscal_ids TO anonymous;
        GRANT SELECT ON TABLE "1".project_fiscal_ids TO web_user;
        GRANT SELECT ON TABLE "1".project_fiscal_ids TO admin;


        DROP VIEW public.project_fiscal_informs;
        DROP MATERIALIZED VIEW public.project_fiscal_datas_matview;
        DROP VIEW public.project_fiscal_datas;
        SQL
    end

    def down
      execute <<-SQL
      SQL
    end
  end
  