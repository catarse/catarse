class AddProjectMetricStorageFunctions < ActiveRecord::Migration
  def up
    execute <<-SQL
create or replace function refresh_project_metric_storage(projects) returns void
  language plpgsql
as $$
declare
    v_data jsonb;
    begin
        if $1.mode = 'sub' then
            -- build jsonb object for subscription project
            select
                json_build_object(
                    'pledged', coalesce(subs_agg.sum_active, 0),
                    'total_contributions', coalesce(subs_agg.count_active, 0),
                    'total_contributors', coalesce(subs_agg.count_per_user, 0),
                    'progress', coalesce((
                        (coalesce(subs_agg.sum_active, 0) / coalesce(goals_agg.min_value, goals_agg.max_value)) * 100::numeric
                    ), 0)
                )::jsonb
            from public.projects p
                -- subscriptions aggregations
                left join lateral (
                    select
                        sum(sub_data.amount) as sum_active,
                        count(1) as count_active,
                        count(distinct(sub.user_id)) as count_per_user
                    from common_schema.subscriptions sub
                        left join lateral (
                            select
                                (sub.checkout_data->>'amount'::text)::numeric as amount_in_cents,
                                ((sub.checkout_data->>'amount'::text)::numeric / (100)::numeric) as amount
                        ) as sub_data on true
                        where sub.project_id = p.common_id and sub.status = 'active'
                ) as subs_agg on true
                -- goals aggregations
                left join lateral (
                    select
                        min(g.value) filter(where g.value > subs_agg.sum_active) as min_value,
                        max(g.value) as max_value
                    from public.goals g
                        where g.project_id = p.id
                ) as goals_agg on true                
            where p.id = $1.id into v_data;
        else
            select json_build_object(
                'pledged', coalesce(pt_data.pledged, 0)::numeric,
                'total_contributions', coalesce(pt.total_contributions, 0),
                'total_contributors', coalesce(pt.total_contributors, 0),
                'progress', coalesce(pt.progress, 0)::numeric
            )::jsonb
            from public.projects p
            left join "1".project_totals pt on pt.project_id = p.id
            left join lateral (
                select
                    (case
                    when p.state = 'failed' then pt.pledged
                    else pt.paid_pledged
                    end) as pledged
            ) as pt_data on true
            where p.id = $1.id
            into v_data;
        end if;

        begin
            insert into public.project_metric_storages (project_id, data, refreshed_at, created_at, updated_at)
                values ($1.id, v_data, now(), now(), now());
        exception when unique_violation then
            update public.project_metric_storages
                set data = v_data,
                    refreshed_at = now(),
                    updated_at = now()
                where project_id = $1.id;
        end;

        return;
    end;
$$;
    SQL
  end

  def down
    execute <<-SQL
drop function public.refresh_project_metric_storage(projects);
    SQL
  end
end
