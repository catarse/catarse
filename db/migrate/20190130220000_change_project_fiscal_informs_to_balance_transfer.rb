class ChangeProjectFiscalInformsToBalanceTransfer < ActiveRecord::Migration
    def up
        execute <<-SQL
        CREATE OR REPLACE VIEW public.project_fiscal_informs_view AS
        select pfd.project_id, pfd.user_id, pfd.mode,
            CASE WHEN c.c>1 THEN (fiscal_year::text||right('000'||c.n,2))::integer ELSE fiscal_year END fiscal_year,
            pfd.fiscal_date,
            pfd.project_pledged_amount, pfd.service_fee, pfd.irrf, pfd.balance, pfd.total_gateway_fee,
            pj.pj_pledged_by_month, pf.pf_pledged_by_month, project_info, user_info, user_address
        from (
            select project_id, user_id, mode,
                fiscal_year,
                max(fiscal_date) as fiscal_date,
                sum(project_pledged_amount) project_pledged_amount,
                sum(service_fee) service_fee,
                sum(irrf) irrf,
                sum(balance) balance,
                sum(total_gateway_fee) total_gateway_fee,
                array_agg(pj_pledged_by_month::text) pj_pledged_by_month,
                array_agg(pf_pledged_by_month::text) pf_pledged_by_month,
                (json_agg(project_info order by fiscal_date desc)->0) project_info,
                (json_agg(user_info order by fiscal_date desc)->0) user_info,
                (json_agg(user_address order by fiscal_date desc)->0) user_address
                        
            from public.project_fiscal_data_tbl pfd
            group by project_id, user_id, mode, fiscal_year
        ) pfd
        left join lateral (
            select count(user_id) c, min(n)FILTER(where t.user_id=pfd.user_id) n from ( 
                select user_id, row_number() OVER(ORDER BY user_id) n from (
                    select distinct user_id
                    from public.project_fiscal_data_tbl f
                    where f.project_id=pfd.project_id and f.fiscal_year=pfd.fiscal_year
                )t
            )t
        ) c on true
        left join lateral (
            select array_agg(json_build_object('year',year,'month',month,'value',value) order by year, month) pj_pledged_by_month
            from (
                select (x->>'year')::integer as year, (x->>'month')::integer as month, sum((x->>'value')::numeric) as value
                from ( select unnest(p.p::json[]) x from unnest(pfd.pj_pledged_by_month) p(p) )t
                group by year, month
            )t
        ) pj on pj is not null
        left join lateral (
            select array_agg(json_build_object('year',year,'month',month,'value',value) order by year, month) pf_pledged_by_month
            from (
                select (x->>'year')::integer as year, (x->>'month')::integer as month, sum((x->>'value')::numeric) as value
                from ( select unnest(p.p::json[]) x from unnest(pfd.pf_pledged_by_month) p(p) )t
                group by year, month
            )t
        ) pf on pf is not null;


        CREATE OR REPLACE VIEW "1".project_fiscal_ids AS
        select pfd.project_id,
          array_agg(fiscal_date ORDER BY fiscal_date) debit_notes,
          (select array_agg(distinct fiscal_year ORDER BY fiscal_year)
          from public.project_fiscal_informs_view i
          where i.project_id=pfd.project_id
            and left(i.fiscal_year::text,4)::integer<extract(year from current_timestamp)
          ) informs
        from public.project_fiscal_data_tbl pfd
        where is_owner_or_admin(user_id)
        group by pfd.project_id;

        GRANT SELECT ON TABLE "1".project_fiscal_ids TO anonymous;
        GRANT SELECT ON TABLE "1".project_fiscal_ids TO web_user;
        GRANT SELECT ON TABLE "1".project_fiscal_ids TO admin;


        alter table project_fiscal_data_tbl add COLUMN balance_transfer_id integer;
        alter table project_fiscal_data_tbl add COLUMN subscription_payment_uuids uuid[];
        alter table project_fiscal_data_tbl add COLUMN payment_ids	integer[];



        CREATE VIEW public.project_fiscal_data_tbl_refresh_supportview AS
        select r.project_id,
            r.user_id,
            pr.mode as mode,
            to_char(zone_timestamp(r.transferred_at),'YYYYMMDD') fiscal_date,
            extract(year from zone_timestamp(r.transferred_at)::date)::integer fiscal_year,
            
            round(r.project_pledged_amount,2) as project_pledged_amount,
            round(r.total_service_fee,2) as service_fee,
            
            round(NULLIF(irrf_tax,0),2) as irrf,
            -- r.project_contribution_confirmed_after_finished nao entra pq está somado em payments
            round( (r.payments+
                +chargeback_after_finished+contribution_refunded_after_successful_pledged)
                +COALESCE(r.service_fee,0)+COALESCE(r.irrf_tax,0),2) balance,

            pa.total_gateway_fee,

            pa.pj_pledged_by_month,
            pa.pf_pledged_by_month,
            to_json(pr) as project_info,
            to_json(u) as user_info,
            to_json(ad) as user_address,
            r.balance_transfer_id,
            r.subscription_payment_uuids,
            r.payment_ids,
            r.payments as total_payments,
            r.requested_at,
            r.transferred_at
        from public.balance_transfer_requests_projects_view r
        join projects pr on pr.id=r.project_id and pr.state not in ('deleted','rejected','failed')
        join users u on u.id=r.user_id
        left join addresses ad on ad.id=u.address_id
        join lateral (
            select round(sum(q.value),2) as payment_amount,
                round(sum(q.gateway_fee),2) as total_gateway_fee,
                array_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where q.is_pj) as pj_pledged_by_month,
                array_agg(json_build_object('year',q.year, 'month',q.month, 'value',q.value))FILTER(where not q.is_pj) as pf_pledged_by_month
            from (
            (
            --  os projetos 34751 e 52473 (transações 83637 e 57508) nao geraram value aqui pq o pagamento foi creditado no balanco do usuario muuuito depois de pago! Como tratar isso?
                select date_part('year', zone_timestamp(pa.paid_at)) AS "year",
                    date_part('month', zone_timestamp(pa.paid_at)) AS "month",
                    (pa.gateway_data->'customer'->> 'document_type') IS NOT NULL AND (pa.gateway_data->'customer'->>'document_type')='cnpj' AS is_pj,
                    sum(pa.value) AS value,
                    sum(pa.gateway_fee) as gateway_fee
                from payments pa
                where pr.mode<>'sub'
            and pa.id=ANY(r.payment_ids)
                GROUP BY 1,2,3
            ) UNION (
                SELECT date_part('year', zpaid_at) AS "year",
                    date_part('month', zpaid_at) AS "month",
                    (pa.gateway_general_data ->> 'customer_document_type') IS NOT NULL AND (pa.gateway_general_data ->> 'customer_document_type')='cnpj' AS is_pj,
                    round(sum((pa.data ->> 'amount')::numeric / 100::numeric),2) AS value,
                    round(sum( (CASE WHEN (pa.gateway_general_data ->> 'gateway_payment_method')='credit_card'
                                THEN COALESCE((pa.gateway_general_data->>'gateway_cost')::numeric,0)+COALESCE((pa.gateway_general_data->>'payable_total_fee')::numeric,0)
                                ELSE COALESCE((pa.gateway_general_data->>'gateway_cost'),(pa.gateway_general_data->>'payable_total_fee'))::numeric END
                        ) / 100::numeric),2) AS gateway_fee
                from common_schema.catalog_payments pa
                JOIN LATERAL (
                    select zone_timestamp(ptp.created_at) as zpaid_at
                    from common_schema.payment_status_transitions ptp
                    where ptp.catalog_payment_id = pa.id
                    and ptp.to_status = 'paid'
                    order by ptp.created_at desc limit 1
                ) ptp on true
                WHERE pr.mode='sub'
                and pa.project_id=pr.common_id
                and pa.id=ANY(r.subscription_payment_uuids)
                GROUP BY 1,2,3
            )
            ORDER BY 1,2,3
            )q where (q.value is not null)
        ) pa on true
        where r.project_id is not null and r.project_id<>69026
        order by r.transferred_at desc;

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
            and (r.total_payments>0)
            and (r.mode='sub' or zone_timestamp(r.transferred_at)::date>='20190101');

            GET DIAGNOSTICS b_count = ROW_COUNT;
            RAISE NOTICE 'project_fiscal_data_tbl_refresh inserted % new rows', b_count;
            RETURN b_count;
        END;
        $function$;

        SQL
    end

    def down
      execute <<-SQL
      CREATE OR REPLACE VIEW "public"."project_fiscal_informs_view" AS 
      SELECT pfd.project_id,
          pfd.user_id,
          pfd.mode,
          pfd.fiscal_year,
          max(pfd.fiscal_date) AS fiscal_date,
          sum(pfd.project_pledged_amount) AS project_pledged_amount,
          sum(pfd.service_fee) AS service_fee,
          sum(pfd.irrf) AS irrf,
          sum(pfd.balance) AS balance,
          sum(pfd.total_gateway_fee) AS total_gateway_fee,
          min(pj.pledged_by_month) AS pj_pledged_by_month,
          min(pf.pledged_by_month) AS pf_pledged_by_month,
          (json_agg(pfd.project_info) -> 0) AS project_info,
          (json_agg(pfd.user_info) -> 0) AS user_info,
          (json_agg(pfd.user_address) -> 0) AS user_address
        FROM ((project_fiscal_data_tbl pfd
          LEFT JOIN LATERAL ( SELECT array_agg(p.p ORDER BY (p.p ->> 'year'::text), (p.p ->> 'month'::text)) AS pledged_by_month
                FROM unnest(pfd.pj_pledged_by_month) p(p)
                WHERE (p.p IS NOT NULL)) pj ON (true))
          LEFT JOIN LATERAL ( SELECT array_agg(p.p ORDER BY (p.p ->> 'year'::text), (p.p ->> 'month'::text)) AS pledged_by_month
                FROM unnest(pfd.pf_pledged_by_month) p(p)
                WHERE (p.p IS NOT NULL)) pf ON (true))
        GROUP BY pfd.project_id, pfd.user_id, pfd.mode, pfd.fiscal_year;

      CREATE OR REPLACE VIEW "1"."project_fiscal_ids" AS 
      SELECT pfd.project_id,
          array_agg(pfd.fiscal_date ORDER BY pfd.fiscal_date) AS debit_notes,
          array_agg(DISTINCT pfd.fiscal_year ORDER BY pfd.fiscal_year) FILTER (WHERE ((pfd.mode <> 'sub'::text) OR ((pfd.fiscal_year)::double precision < date_part('year'::text, now())))) AS informs
        FROM project_fiscal_data_tbl pfd
        WHERE is_owner_or_admin(pfd.user_id)
        GROUP BY pfd.project_id;

      GRANT SELECT ON TABLE "1".project_fiscal_ids TO anonymous;
      GRANT SELECT ON TABLE "1".project_fiscal_ids TO web_user;
      GRANT SELECT ON TABLE "1".project_fiscal_ids TO admin;


      alter table project_fiscal_data_tbl drop COLUMN balance_transfer_id;
      alter table project_fiscal_data_tbl drop COLUMN subscription_payment_uuids;
      alter table project_fiscal_data_tbl drop COLUMN payment_ids;
      

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
              left join balance_transactions btfee on btfee.user_id=pr.user_id and btfee.project_id=pr.id and btfee.event_name='catarse_project_service_fee'
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

      SQL
    end
  end
  