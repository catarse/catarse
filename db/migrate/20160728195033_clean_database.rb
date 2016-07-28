class CleanDatabase < ActiveRecord::Migration
  def change
    execute <<-SQL

    CREATE OR REPLACE VIEW financial.project_metrics_with_generated_series AS
    SELECT p.permalink,
    ct.name_pt AS categoria,
    p.state,
    COALESCE(pt.total_contributions, 0::bigint) AS total_contributions,
    round(pt.pledged / pt.total_contributions::numeric, 2) AS media_apoio,
    COALESCE(round(pt.progress, 2), 0::numeric) AS percentual_arrecadado,
    COALESCE(pt.pledged, 0::numeric) AS pledged,
    p.goal,
    timezone('America/Sao_Paulo'::text, online_at(p.*))::date AS data_online,
    zone_expires_at(p.*)::date AS data_expiracao,
    p.online_days,
        CASE
            WHEN now() > (online_at(p.*) + '3 days'::interval) THEN COALESCE(round(pt.days_3, 2), 0::numeric)
            ELSE NULL::numeric
        END AS "3 dias",
        CASE
            WHEN now() > (online_at(p.*) + '7 days'::interval) THEN COALESCE(round(pt.days_7, 2), 0::numeric)
            ELSE NULL::numeric
        END AS "7 dias",
        CASE
            WHEN now() > (online_at(p.*) + (p.expires_at - online_at(p.*)) / 4::double precision) THEN COALESCE(round(pt.fst_quarter, 2), 0::numeric)
            ELSE NULL::numeric
        END AS "1 quartil",
        CASE
            WHEN now() > (online_at(p.*) + (p.expires_at - online_at(p.*)) / 2::double precision) THEN COALESCE(round(pt.fst_half, 2), 0::numeric)
            ELSE NULL::numeric
        END AS metade,
        CASE
            WHEN now() > (online_at(p.*) + 3::double precision * (p.expires_at - online_at(p.*)) / 4::double precision) THEN COALESCE(round(pt.trd_quarter, 2), 0::numeric)
            ELSE NULL::numeric
        END AS "3 quartil",
    ( SELECT count(*) AS count
           FROM project_posts pp
          WHERE pp.project_id = p.id) AS novidades,
    ( SELECT count(*) AS count
           FROM projects p2
          WHERE p2.user_id = p.user_id AND state_order(p2.*) >= 'published'::project_state_order) AS projetos_realizdor
   FROM projects p
     JOIN categories ct ON ct.id = p.category_id
     LEFT JOIN ( SELECT c.project_id,
            sum(p_1.value) AS pledged,
            sum(p_1.value) / projects.goal * 100::numeric AS progress,
            count(DISTINCT c.id) AS total_contributions,
            sum(p_1.value) FILTER (WHERE p_1.paid_at <= (online_at(projects.*) + '3 days'::interval)) / projects.goal * 100::numeric AS days_3,
            sum(p_1.value) FILTER (WHERE p_1.paid_at <= (online_at(projects.*) + '7 days'::interval)) / projects.goal * 100::numeric AS days_7,
            sum(p_1.value) FILTER (WHERE p_1.paid_at <= (online_at(projects.*) + (projects.expires_at - online_at(projects.*)) / 4::double precision)) / projects.goal * 100::numeric AS fst_quarter,
            sum(p_1.value) FILTER (WHERE p_1.paid_at <= (online_at(projects.*) + (projects.expires_at - online_at(projects.*)) / 2::double precision)) / projects.goal * 100::numeric AS fst_half,
            sum(p_1.value) FILTER (WHERE p_1.paid_at <= (online_at(projects.*) + 3::double precision * (projects.expires_at - online_at(projects.*)) / 4::double precision)) / projects.goal * 100::numeric AS trd_quarter
           FROM contributions c
             JOIN projects ON c.project_id = projects.id
             JOIN payments p_1 ON p_1.contribution_id = c.id
          WHERE (p_1.state = ANY (confirmed_states())) AND online_at(projects.*) > '2015-10-01'::date
          GROUP BY c.project_id, projects.id) pt ON pt.project_id = p.id
  WHERE ((p.state::text <> ALL (ARRAY['draft'::character varying::text, 'in_analysis'::character varying::text, 'rejected'::character varying::text]))) AND online_at(p.*) > '2015-10-01'::date
  ORDER BY (date_part('epoch'::text, now() - online_at(p.*)::timestamp with time zone) / date_part('epoch'::text, p.expires_at - online_at(p.*)));



   drop table flexible_project_transitions;
   drop table flexible_projects;
   drop table flexible_project_states;
   drop table project_budgets;
    SQL
  end
end
