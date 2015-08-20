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

      drop view "1".project_details;
      create view "1".project_details as
        select
          p.id as project_id,
          coalesce(pt.progress, 0) as progress,
          coalesce(pt.pledged, 0) as pledged,
          coalesce(pt.total_contributions, 0) as total_contributions,
          p.state,
          p.is_published,
          p.expires_at,
          p.sent_to_analysis_at,
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
