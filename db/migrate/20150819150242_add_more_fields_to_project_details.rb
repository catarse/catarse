class AddMoreFieldsToProjectDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
      drop function if exists public.published_states();
      CREATE FUNCTION public.published_states() RETURNS text[]
        LANGUAGE sql STABLE SECURITY DEFINER
          AS $$
            SELECT '{"online", "waiting_funds", "failed", "successful"}'::text[];
          $$;

      drop function if exists public.is_published(projects);
      create function public.is_published(projects) returns boolean
        language sql stable SECURITY DEFINER
        as $$
          select true where $1.state = ANY(public.published_states());
        $$;

      drop function if exists public.is_expired(projects);
      CREATE FUNCTION public.is_expired(projects) RETURNS boolean
        LANGUAGE sql STABLE SECURITY DEFINER
          AS $$
            SELECT (current_timestamp > $1.expires_at);
          $$;

      drop function if exists public.open_for_contributions(projects);
      CREATE FUNCTION public.open_for_contributions(projects) RETURNS boolean
        LANGUAGE sql STABLE SECURITY DEFINER
          AS $$
            SELECT (not $1.is_expired AND $1.state = 'online')
          $$;

      drop function if exists public.remaining_time_interval(projects);
      CREATE FUNCTION public.remaining_time_interval(projects) RETURNS interval
        LANGUAGE sql STABLE SECURITY DEFINER
          AS $$
            select ($1.expires_at - current_timestamp)::interval
          $$;

      drop function if exists public.remaining_time_json(projects);
      CREATE FUNCTION public.remaining_time_json(projects) RETURNS json
        LANGUAGE sql STABLE SECURITY DEFINER
          AS $$
            select (
              case
              when $1.is_expired then
                json_build_object('total', 0, 'unit', 'seconds')
              else
                case
                when $1.remaining_time_interval >= '1 day'::interval then
                  json_build_object('total', extract(day from $1.remaining_time_interval), 'unit', 'days')
                when $1.remaining_time_interval >= '1 hour'::interval and $1.remaining_time_interval < '24 hours'::interval then
                  json_build_object('total', extract(hour from $1.remaining_time_interval), 'unit', 'hours')
                when $1.remaining_time_interval >= '1 minute'::interval and $1.remaining_time_interval < '60 minutes'::interval then
                  json_build_object('total', extract(minutes from $1.remaining_time_interval), 'unit', 'minutes')
                when $1.remaining_time_interval < '60 seconds'::interval then
                  json_build_object('total', extract(seconds from $1.remaining_time_interval), 'unit', 'seconds')
                 else json_build_object('total', 0, 'unit', 'seconds') end
              end
            )
        $$;

      drop view "1".project_details;
      create view "1".project_details as
        select
          p.id as project_id,
          coalesce(pt.progress, 0) as progress,
          coalesce(pt.pledged, 0) as pledged,
          coalesce(pt.total_contributions, 0) as total_contributions,
          p.state,
          p.expires_at,
          p.online_date,
          p.sent_to_analysis_at,
          p.is_published,
          p.is_expired,
          p.open_for_contributions,
          p.remaining_time_json as remaining_time,
          (
            select
              json_build_object('id', u.id, 'name', u.name)
            from users u where u.id = p.user_id
          ) as user,
          json_agg(row_to_json(rd.*)) as rewards,
          count(pn.*) filter (where pn.template_name = 'reminder') as reminder_count
        from projects p
        left join "1".project_totals pt on pt.project_id = p.id
        left join "1".reward_details rd on rd.project_id = p.id
        left join public.project_notifications pn on pn.project_id = p.id
        group by
          p.id,
          pt.progress,
          pt.pledged,
          pt.total_contributions,
          p.state,
          p.expires_at,
          p.sent_to_analysis_at,
          pt.total_payment_service_fee;

      grant select on "1".project_details to admin;
      grant select on "1".project_details to web_user;
      grant select on "1".project_details to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      drop function if exists public.is_published(projects) cascade;
      drop function if exists public.published_states();

      drop view if exists "1".project_details;
      create view "1".project_details as
        select
          pt.*,
          p.state,
          p.expires_at,
          json_agg(row_to_json(rd.*)) as rewards
        from projects p
        left join "1".project_totals pt on pt.project_id = p.id
        left join "1".reward_details rd on rd.project_id = p.id
        group by
          pt.project_id,
          pt.progress,
          pt.pledged,
          pt.total_contributions,
          p.state,
          p.expires_at,
          pt.total_payment_service_fee;

      grant select on "1".project_details to admin;
      grant select on "1".project_details to web_user;
      grant select on "1".project_details to anonymous;
    SQL
  end
end
