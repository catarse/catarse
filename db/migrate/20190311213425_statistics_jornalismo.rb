class StatisticsJornalismo < ActiveRecord::Migration
  def up
    execute <<-SQL

-- based on function analytics_service_api.project_subscribers_info(id uuid)
create materialized view "1".statistics_jornalismo AS
select *
from (
    select
        round(COALESCE(sum(last_payment.amount) / 100, 0),2) total_amount,
        count(distinct pr.id) projects,
        count(distinct s.id)FILTER(where pr.permalink='intercept') intercept_subscribers,
        round(sum(last_payment.amount)FILTER(where pr.permalink='intercept')/100,2) intercept_amount,
        count(distinct s.id)FILTER(where pr.permalink='azmina') azmina_subscribers,
        round(sum(last_payment.amount)FILTER(where pr.permalink='azmina')/100,2) azmina_amount,
        count(distinct s.id)FILTER(where pr.permalink='mamilos') mamilos_subscribers,
        round(sum(last_payment.amount)FILTER(where pr.permalink='mamilos')/100,2) mamilos_amount
    
    from projects pr
    join common_schema.subscriptions s on s.project_id = pr.common_id and s.status='active'
    left join lateral (
        select (cp.data ->> 'amount')::decimal as amount
        from common_schema.catalog_payments cp
        where -- payment_service.paid_transition_at(cp) + core.get_setting('subscription_interval')::interval > now()
            cp.status in ('paid', 'pending')
            and cp.subscription_id = s.id
        order by cp.created_at desc
        limit 1
    ) as last_payment on true
    where pr.category_id=15 and pr.mode='sub' and pr.state='online'
)t
left join (
    select count(*) total_subscribers,
        count(*)FILTER(where num_subs>=2) total_subscribers_2
    from (
        select user_id, count(*) num_subs
        from common_schema.subscriptions s
        where s.status='active'
        group by user_id
    )t
)s on true;

create unique index statistics_jornalismo_idx on "1".statistics_jornalismo(projects);

grant select on "1".statistics_jornalismo to admin;
grant select on "1".statistics_jornalismo to web_user;
grant select on "1".statistics_jornalismo to anonymous;

    SQL
  end

  def down
    execute <<-SQL
      drop materialized view "1".statistics_jornalismo;
    SQL
  end
end
