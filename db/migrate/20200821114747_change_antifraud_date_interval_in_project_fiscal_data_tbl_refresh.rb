class ChangeAntifraudDateIntervalInProjectFiscalDataTblRefresh < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW public.project_fiscal_data_tbl_refresh_supportview AS
      SELECT r.project_id,
        r.user_id,
        pr.mode,
        to_char(zone_timestamp(r.transferred_at), 'YYYYMMDD'::text) AS fiscal_date,
        date_part('year'::text, zone_timestamp(r.transferred_at)::date)::integer AS fiscal_year,
        round(r.project_pledged_amount, 2) AS project_pledged_amount,
        round(r.total_service_fee, 2) AS service_fee,
        round(NULLIF(r.irrf_tax, 0::numeric), 2) AS irrf,
        round(r.payments + (+ r.chargeback_after_finished) + r.contribution_refunded_after_successful_pledged + COALESCE(r.service_fee, 0::numeric) + COALESCE(r.irrf_tax, 0::numeric), 2) AS balance,
        pa.total_gateway_fee,
        pa.pj_pledged_by_month,
        pa.pf_pledged_by_month,
        to_json(pr.*) AS project_info,
        to_json(u.*) AS user_info,
        to_json(ad.*) AS user_address,
        r.balance_transfer_id,
        r.subscription_payment_uuids,
        r.payment_ids,
        r.payments AS total_payments,
        r.requested_at,
        r.transferred_at,
        pa.total_antifraud_cost
      FROM balance_transfer_requests_projects_view r
        JOIN projects pr ON pr.id = r.project_id AND (pr.state::text <> ALL (ARRAY['deleted'::character varying::text, 'rejected'::character varying::text, 'failed'::character varying::text]))
        JOIN users u ON u.id = r.user_id
        LEFT JOIN addresses ad ON ad.id = u.address_id
        JOIN LATERAL ( SELECT round(sum(q.value), 2) AS payment_amount,
                round(sum(q.gateway_fee), 2) AS total_gateway_fee,
                round(sum(q.antifraud_cost), 2) AS total_antifraud_cost,
                array_agg(json_build_object('year', q.year, 'month', q.month, 'value', q.value)) FILTER (WHERE q.is_pj) AS pj_pledged_by_month,
                array_agg(json_build_object('year', q.year, 'month', q.month, 'value', q.value)) FILTER (WHERE NOT q.is_pj) AS pf_pledged_by_month
              FROM ( SELECT date_part('year'::text, zone_timestamp(pa_1.paid_at)) AS year,
                        date_part('month'::text, zone_timestamp(pa_1.paid_at)) AS month,
                        ((pa_1.gateway_data -> 'customer'::text) ->> 'document_type'::text) IS NOT NULL AND ((pa_1.gateway_data -> 'customer'::text) ->> 'document_type'::text) = 'cnpj'::text AS is_pj,
                        sum(pa_1.value) AS value,
                        sum(pa_1.gateway_fee) AS gateway_fee,
                        sum(aa_1.cost) AS antifraud_cost
                      FROM payments pa_1
                      LEFT JOIN antifraud_analyses aa_1 ON aa_1.payment_id = pa_1.id AND aa_1.created_at::date >= '2020-08-01'::date
                      WHERE pr.mode <> 'sub'::text AND (pa_1.id = ANY (r.payment_ids))
                      GROUP BY (date_part('year'::text, zone_timestamp(pa_1.paid_at))), (date_part('month'::text, zone_timestamp(pa_1.paid_at))), (((pa_1.gateway_data -> 'customer'::text) ->> 'document_type'::text) IS NOT NULL AND ((pa_1.gateway_data -> 'customer'::text) ->> 'document_type'::text) = 'cnpj'::text)
                    UNION
                    SELECT date_part('year'::text, ptp.zpaid_at) AS year,
                        date_part('month'::text, ptp.zpaid_at) AS month,
                        (pa_1.gateway_general_data ->> 'customer_document_type'::text) IS NOT NULL AND (pa_1.gateway_general_data ->> 'customer_document_type'::text) = 'cnpj'::text AS is_pj,
                        round(sum(((pa_1.data ->> 'amount'::text)::numeric) / 100::numeric), 2) AS value,
                        round(sum(
                            CASE
                                WHEN (pa_1.gateway_general_data ->> 'gateway_payment_method'::text) = 'credit_card'::text THEN COALESCE((pa_1.gateway_general_data ->> 'gateway_cost'::text)::numeric, 0::numeric) + COALESCE((pa_1.gateway_general_data ->> 'payable_total_fee'::text)::numeric, 0::numeric)
                                ELSE COALESCE(pa_1.gateway_general_data ->> 'gateway_cost'::text, pa_1.gateway_general_data ->> 'payable_total_fee'::text)::numeric
                            END / 100::numeric), 2) AS gateway_fee,
                        round(sum(aa_1.cost), 2) AS antifraud_cost
                      FROM unnest(r.subscription_payment_uuids) spu(spu)
                        JOIN common_schema.catalog_payments pa_1 ON pa_1.id = spu.spu AND pa_1.project_id = pr.common_id
                        LEFT JOIN common_schema.antifraud_analyses aa_1 ON aa_1.catalog_payment_id = pa_1.id AND aa_1.created_at::date >= '2020-08-01'::date
                        JOIN LATERAL ( SELECT zone_timestamp(ptp_1.created_at) AS zpaid_at
                              FROM common_schema.payment_status_transitions ptp_1
                              WHERE ptp_1.catalog_payment_id = pa_1.id AND ptp_1.to_status = 'paid'::payment_service.payment_status
                              ORDER BY ptp_1.created_at DESC
                            LIMIT 1) ptp ON true
                      WHERE pr.mode = 'sub'::text
                      GROUP BY (date_part('year'::text, ptp.zpaid_at)), (date_part('month'::text, ptp.zpaid_at)), ((pa_1.gateway_general_data ->> 'customer_document_type'::text) IS NOT NULL AND (pa_1.gateway_general_data ->> 'customer_document_type'::text) = 'cnpj'::text)
              ORDER BY 1, 2, 3) q
              WHERE q.value IS NOT NULL) pa ON true
      WHERE r.project_id IS NOT NULL AND r.project_id <> 69026
      ORDER BY r.transferred_at DESC;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE VIEW public.project_fiscal_data_tbl_refresh_supportview AS
      SELECT r.project_id,
        r.user_id,
        pr.mode,
        to_char(zone_timestamp(r.transferred_at), 'YYYYMMDD'::text) AS fiscal_date,
        date_part('year'::text, zone_timestamp(r.transferred_at)::date)::integer AS fiscal_year,
        round(r.project_pledged_amount, 2) AS project_pledged_amount,
        round(r.total_service_fee, 2) AS service_fee,
        round(NULLIF(r.irrf_tax, 0::numeric), 2) AS irrf,
        round(r.payments + (+ r.chargeback_after_finished) + r.contribution_refunded_after_successful_pledged + COALESCE(r.service_fee, 0::numeric) + COALESCE(r.irrf_tax, 0::numeric), 2) AS balance,
        pa.total_gateway_fee,
        pa.pj_pledged_by_month,
        pa.pf_pledged_by_month,
        to_json(pr.*) AS project_info,
        to_json(u.*) AS user_info,
        to_json(ad.*) AS user_address,
        r.balance_transfer_id,
        r.subscription_payment_uuids,
        r.payment_ids,
        r.payments AS total_payments,
        r.requested_at,
        r.transferred_at,
        pa.total_antifraud_cost
      FROM balance_transfer_requests_projects_view r
        JOIN projects pr ON pr.id = r.project_id AND (pr.state::text <> ALL (ARRAY['deleted'::character varying::text, 'rejected'::character varying::text, 'failed'::character varying::text]))
        JOIN users u ON u.id = r.user_id
        LEFT JOIN addresses ad ON ad.id = u.address_id
        JOIN LATERAL ( SELECT round(sum(q.value), 2) AS payment_amount,
                round(sum(q.gateway_fee), 2) AS total_gateway_fee,
                round(sum(q.antifraud_cost), 2) AS total_antifraud_cost,
                array_agg(json_build_object('year', q.year, 'month', q.month, 'value', q.value)) FILTER (WHERE q.is_pj) AS pj_pledged_by_month,
                array_agg(json_build_object('year', q.year, 'month', q.month, 'value', q.value)) FILTER (WHERE NOT q.is_pj) AS pf_pledged_by_month
              FROM ( SELECT date_part('year'::text, zone_timestamp(pa_1.paid_at)) AS year,
                        date_part('month'::text, zone_timestamp(pa_1.paid_at)) AS month,
                        ((pa_1.gateway_data -> 'customer'::text) ->> 'document_type'::text) IS NOT NULL AND ((pa_1.gateway_data -> 'customer'::text) ->> 'document_type'::text) = 'cnpj'::text AS is_pj,
                        sum(pa_1.value) AS value,
                        sum(pa_1.gateway_fee) AS gateway_fee,
                        sum(aa_1.cost) AS antifraud_cost
                      FROM payments pa_1
                      LEFT JOIN antifraud_analyses aa_1 ON aa_1.payment_id = pa_1.id
                      WHERE pr.mode <> 'sub'::text AND (pa_1.id = ANY (r.payment_ids))
                      GROUP BY (date_part('year'::text, zone_timestamp(pa_1.paid_at))), (date_part('month'::text, zone_timestamp(pa_1.paid_at))), (((pa_1.gateway_data -> 'customer'::text) ->> 'document_type'::text) IS NOT NULL AND ((pa_1.gateway_data -> 'customer'::text) ->> 'document_type'::text) = 'cnpj'::text)
                    UNION
                    SELECT date_part('year'::text, ptp.zpaid_at) AS year,
                        date_part('month'::text, ptp.zpaid_at) AS month,
                        (pa_1.gateway_general_data ->> 'customer_document_type'::text) IS NOT NULL AND (pa_1.gateway_general_data ->> 'customer_document_type'::text) = 'cnpj'::text AS is_pj,
                        round(sum(((pa_1.data ->> 'amount'::text)::numeric) / 100::numeric), 2) AS value,
                        round(sum(
                            CASE
                                WHEN (pa_1.gateway_general_data ->> 'gateway_payment_method'::text) = 'credit_card'::text THEN COALESCE((pa_1.gateway_general_data ->> 'gateway_cost'::text)::numeric, 0::numeric) + COALESCE((pa_1.gateway_general_data ->> 'payable_total_fee'::text)::numeric, 0::numeric)
                                ELSE COALESCE(pa_1.gateway_general_data ->> 'gateway_cost'::text, pa_1.gateway_general_data ->> 'payable_total_fee'::text)::numeric
                            END / 100::numeric), 2) AS gateway_fee,
                        round(sum(aa_1.cost), 2) AS antifraud_cost
                      FROM unnest(r.subscription_payment_uuids) spu(spu)
                        JOIN common_schema.catalog_payments pa_1 ON pa_1.id = spu.spu AND pa_1.project_id = pr.common_id
                        LEFT JOIN common_schema.antifraud_analyses aa_1 ON aa_1.catalog_payment_id = pa_1.id
                        JOIN LATERAL ( SELECT zone_timestamp(ptp_1.created_at) AS zpaid_at
                              FROM common_schema.payment_status_transitions ptp_1
                              WHERE ptp_1.catalog_payment_id = pa_1.id AND ptp_1.to_status = 'paid'::payment_service.payment_status
                              ORDER BY ptp_1.created_at DESC
                            LIMIT 1) ptp ON true
                      WHERE pr.mode = 'sub'::text
                      GROUP BY (date_part('year'::text, ptp.zpaid_at)), (date_part('month'::text, ptp.zpaid_at)), ((pa_1.gateway_general_data ->> 'customer_document_type'::text) IS NOT NULL AND (pa_1.gateway_general_data ->> 'customer_document_type'::text) = 'cnpj'::text)
              ORDER BY 1, 2, 3) q
              WHERE q.value IS NOT NULL) pa ON true
      WHERE r.project_id IS NOT NULL AND r.project_id <> 69026
      ORDER BY r.transferred_at DESC;
    SQL
  end
end
