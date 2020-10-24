class AddRefreshRewardMetricStorageFn < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL

CREATE OR REPLACE FUNCTION public.refresh_reward_metric_storage(arg_r rewards)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
    v_data jsonb;
begin
    select
        json_build_object(
            'paid_count', coalesce(public.paid_count(arg_r), 0),
            'waiting_payment_count', coalesce(public.waiting_payment_count(arg_r), 0)
        )::jsonb
    into v_data;

    insert into public.reward_metric_storages (reward_id, data, refreshed_at, created_at, updated_at)
        values (arg_r.id, v_data, now(), now(), now())
    on conflict (reward_id)
        do update set
            data = excluded.data,
            refreshed_at = excluded.refreshed_at,
            updated_at = excluded.updated_at;

    return;
end;
$function$;
    SQL
  end
end
