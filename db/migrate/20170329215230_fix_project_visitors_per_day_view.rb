class FixProjectVisitorsPerDayView < ActiveRecord::Migration
  def up
    execute <<-SQL
DROP MATERIALIZED VIEW "1".project_visitors_per_day;
CREATE MATERIALIZED VIEW "1".project_visitors_per_day AS 
select i.project_id, sum(visitors) as total,
    json_agg(json_build_object('day', i.day, 'visitors', i.visitors)) AS source
from (
  select p.id as project_id,
      to_char(zone_timestamp(n.created_at),'YYYY-MM-DD') as day,
      --count(*) as visitas,
      count(distinct n.ctrse_sid) as visitors
      --count(distinct n.user_id) as visitantes_logados
  from public.moments_navigations n
  join projects p on p.id=n.project_id
  join project_transitions pt on pt.project_id=p.id and pt.to_state='online'
  left join lateral (
    select id, created_at
    from project_transitions ptf
    where ptf.project_id=p.id and ptf.to_state in ('waiting_funds','successful','failed')
    order by created_at
    limit 1
  ) ptf on true
  where n.created_at>=pt.created_at and (ptf is null or n.created_at<=ptf.created_at) and (n.user_id is null or n.user_id<>p.user_id) and n.path !~ '^/projects/\d+/.+' --and n.created_at >= now()-'6 days'::interval
  group by p.id, day
  order by p.id, day
)i
group by i.project_id
WITH NO DATA;


GRANT SELECT ON TABLE "1".project_visitors_per_day TO anonymous;
GRANT SELECT ON TABLE "1".project_visitors_per_day TO web_user;
GRANT SELECT ON TABLE "1".project_visitors_per_day TO admin;
    SQL
  end

  def down
    execute <<-SQL
 DROP MATERIALIZED VIEW "1".project_visitors_per_day;
CREATE MATERIALIZED VIEW "1".project_visitors_per_day AS 
select i.project_id, sum(visitors) as total,
    json_agg(json_build_object('day', i.day, 'visitors', i.visitors)) AS source
from (
  select p.id as project_id,
      to_char(zone_timestamp(n.created_at),'YYYY-MM-DD') as day,
      --count(*) as visitas,
      count(distinct n.ctrse_sid) as visitors
      --count(distinct n.user_id) as visitantes_logados
  from public.moments_navigations n
  join projects p on p.id=n.project_id
  join project_transitions pt on pt.project_id=p.id and pt.to_state='online'
  left join project_transitions ptf on ptf.project_id=p.id and ptf.to_state in ('successful','failed')
  where n.created_at>=pt.created_at and (ptf is null or n.created_at<=ptf.created_at) and (n.user_id is null or n.user_id<>p.user_id) and n.path !~ '^/projects/\d+/.+' --and n.created_at >= now()-'6 days'::interval
  group by p.id, day
  order by p.id, day
)i
group by i.project_id
WITH NO DATA;

GRANT SELECT ON TABLE "1".project_visitors_per_day TO anonymous;
GRANT SELECT ON TABLE "1".project_visitors_per_day TO web_user;
GRANT SELECT ON TABLE "1".project_visitors_per_day TO admin;
    SQL
  end
end
