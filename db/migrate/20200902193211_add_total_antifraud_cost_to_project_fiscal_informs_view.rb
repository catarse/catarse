class AddTotalAntifraudCostToProjectFiscalInformsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW public.project_fiscal_informs_view
      AS SELECT pfd.project_id,
          pfd.user_id,
          pfd.mode,
              CASE
                  WHEN c.c > 1 THEN (pfd.fiscal_year::text || "right"('000'::text || c.n, 2))::integer
                  ELSE pfd.fiscal_year
              END AS fiscal_year,
          pfd.fiscal_date,
          pfd.project_pledged_amount,
          pfd.service_fee,
          pfd.irrf,
          pfd.balance,
          pfd.total_gateway_fee,
          pj.pj_pledged_by_month,
          pf.pf_pledged_by_month,
          pfd.project_info,
          pfd.user_info,
          pfd.user_address,
          pfd.total_antifraud_cost
        FROM ( SELECT pfd_1.project_id,
                  pfd_1.user_id,
                  pfd_1.mode,
                  pfd_1.fiscal_year,
                  max(pfd_1.fiscal_date) AS fiscal_date,
                  sum(pfd_1.project_pledged_amount) AS project_pledged_amount,
                  sum(pfd_1.service_fee) AS service_fee,
                  sum(pfd_1.irrf) AS irrf,
                  sum(pfd_1.balance) AS balance,
                  sum(pfd_1.total_gateway_fee) AS total_gateway_fee,
                  sum(pfd_1.total_antifraud_cost) AS total_antifraud_cost,
                  array_agg(pfd_1.pj_pledged_by_month::text) AS pj_pledged_by_month,
                  array_agg(pfd_1.pf_pledged_by_month::text) AS pf_pledged_by_month,
                  json_agg(pfd_1.project_info ORDER BY pfd_1.fiscal_date DESC) -> 0 AS project_info,
                  json_agg(pfd_1.user_info ORDER BY pfd_1.fiscal_date DESC) -> 0 AS user_info,
                  json_agg(pfd_1.user_address ORDER BY pfd_1.fiscal_date DESC) -> 0 AS user_address
                FROM project_fiscal_data_tbl pfd_1
                GROUP BY pfd_1.project_id, pfd_1.user_id, pfd_1.mode, pfd_1.fiscal_year) pfd
          LEFT JOIN LATERAL ( SELECT count(t.user_id) AS c,
                  min(t.n) FILTER (WHERE t.user_id = pfd.user_id) AS n
                FROM ( SELECT t_1.user_id,
                          row_number() OVER (ORDER BY t_1.user_id) AS n
                        FROM ( SELECT DISTINCT f.user_id
                                FROM project_fiscal_data_tbl f
                                WHERE f.project_id = pfd.project_id AND f.fiscal_year = pfd.fiscal_year) t_1) t) c ON true
          LEFT JOIN LATERAL ( SELECT array_agg(json_build_object('year', t.year, 'month', t.month, 'value', t.value) ORDER BY t.year, t.month) AS pj_pledged_by_month
                FROM ( SELECT (t_1.x ->> 'year'::text)::integer AS year,
                          (t_1.x ->> 'month'::text)::integer AS month,
                          sum((t_1.x ->> 'value'::text)::numeric) AS value
                        FROM ( SELECT unnest(p.p::json[]) AS x
                                FROM unnest(pfd.pj_pledged_by_month) p(p)) t_1
                        GROUP BY ((t_1.x ->> 'year'::text)::integer), ((t_1.x ->> 'month'::text)::integer)) t) pj ON pj.* IS NOT NULL
          LEFT JOIN LATERAL ( SELECT array_agg(json_build_object('year', t.year, 'month', t.month, 'value', t.value) ORDER BY t.year, t.month) AS pf_pledged_by_month
                FROM ( SELECT (t_1.x ->> 'year'::text)::integer AS year,
                          (t_1.x ->> 'month'::text)::integer AS month,
                          sum((t_1.x ->> 'value'::text)::numeric) AS value
                        FROM ( SELECT unnest(p.p::json[]) AS x
                                FROM unnest(pfd.pf_pledged_by_month) p(p)) t_1
                        GROUP BY ((t_1.x ->> 'year'::text)::integer), ((t_1.x ->> 'month'::text)::integer)) t) pf ON pf.* IS NOT NULL;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE VIEW public.project_fiscal_informs_view
      AS SELECT pfd.project_id,
          pfd.user_id,
          pfd.mode,
              CASE
                  WHEN c.c > 1 THEN (pfd.fiscal_year::text || "right"('000'::text || c.n, 2))::integer
                  ELSE pfd.fiscal_year
              END AS fiscal_year,
          pfd.fiscal_date,
          pfd.project_pledged_amount,
          pfd.service_fee,
          pfd.irrf,
          pfd.balance,
          pfd.total_gateway_fee,
          pj.pj_pledged_by_month,
          pf.pf_pledged_by_month,
          pfd.project_info,
          pfd.user_info,
          pfd.user_address
        FROM ( SELECT pfd_1.project_id,
                  pfd_1.user_id,
                  pfd_1.mode,
                  pfd_1.fiscal_year,
                  max(pfd_1.fiscal_date) AS fiscal_date,
                  sum(pfd_1.project_pledged_amount) AS project_pledged_amount,
                  sum(pfd_1.service_fee) AS service_fee,
                  sum(pfd_1.irrf) AS irrf,
                  sum(pfd_1.balance) AS balance,
                  sum(pfd_1.total_gateway_fee) AS total_gateway_fee,
                  array_agg(pfd_1.pj_pledged_by_month::text) AS pj_pledged_by_month,
                  array_agg(pfd_1.pf_pledged_by_month::text) AS pf_pledged_by_month,
                  json_agg(pfd_1.project_info ORDER BY pfd_1.fiscal_date DESC) -> 0 AS project_info,
                  json_agg(pfd_1.user_info ORDER BY pfd_1.fiscal_date DESC) -> 0 AS user_info,
                  json_agg(pfd_1.user_address ORDER BY pfd_1.fiscal_date DESC) -> 0 AS user_address
                FROM project_fiscal_data_tbl pfd_1
                GROUP BY pfd_1.project_id, pfd_1.user_id, pfd_1.mode, pfd_1.fiscal_year) pfd
          LEFT JOIN LATERAL ( SELECT count(t.user_id) AS c,
                  min(t.n) FILTER (WHERE t.user_id = pfd.user_id) AS n
                FROM ( SELECT t_1.user_id,
                          row_number() OVER (ORDER BY t_1.user_id) AS n
                        FROM ( SELECT DISTINCT f.user_id
                                FROM project_fiscal_data_tbl f
                                WHERE f.project_id = pfd.project_id AND f.fiscal_year = pfd.fiscal_year) t_1) t) c ON true
          LEFT JOIN LATERAL ( SELECT array_agg(json_build_object('year', t.year, 'month', t.month, 'value', t.value) ORDER BY t.year, t.month) AS pj_pledged_by_month
                FROM ( SELECT (t_1.x ->> 'year'::text)::integer AS year,
                          (t_1.x ->> 'month'::text)::integer AS month,
                          sum((t_1.x ->> 'value'::text)::numeric) AS value
                        FROM ( SELECT unnest(p.p::json[]) AS x
                                FROM unnest(pfd.pj_pledged_by_month) p(p)) t_1
                        GROUP BY ((t_1.x ->> 'year'::text)::integer), ((t_1.x ->> 'month'::text)::integer)) t) pj ON pj.* IS NOT NULL
          LEFT JOIN LATERAL ( SELECT array_agg(json_build_object('year', t.year, 'month', t.month, 'value', t.value) ORDER BY t.year, t.month) AS pf_pledged_by_month
                FROM ( SELECT (t_1.x ->> 'year'::text)::integer AS year,
                          (t_1.x ->> 'month'::text)::integer AS month,
                          sum((t_1.x ->> 'value'::text)::numeric) AS value
                        FROM ( SELECT unnest(p.p::json[]) AS x
                                FROM unnest(pfd.pf_pledged_by_month) p(p)) t_1
                        GROUP BY ((t_1.x ->> 'year'::text)::integer), ((t_1.x ->> 'month'::text)::integer)) t) pf ON pf.* IS NOT NULL;
    SQL
  end
end
