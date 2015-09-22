class UpdateProjectDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
      drop view "1".project_details;
      create view "1".project_details as
        select
          p.id as project_id,
          p.id,
          p.user_id,
          p.name,
          p.headline,
          p.budget,
          p.goal,
          p.about_html,
          p.permalink,
          p.video_embed_url,
          p.video_url,
          c.name_pt as category_name,
          c.id as category_id,
          coalesce(pt.progress, 0) as progress,
          coalesce(pt.pledged, 0) as pledged,
          coalesce(pt.total_contributions, 0) as total_contributions,
          p.state,
          p.expires_at,
          p.zone_expires_at,
          p.online_date,
          p.sent_to_analysis_at,
          p.is_published,
          p.is_expired,
          p.open_for_contributions,
          p.online_days,
          p.remaining_time_json as remaining_time,
          (select count(pp.*) from project_posts pp where pp.project_id = p.id) as posts_count,
          (
            json_build_object('city', coalesce(ct.name, u.address_city), 'state_acronym', coalesce(st.acronym, u.address_state), 'state', coalesce(st.name, u.address_state))
          ) as address,
          (
            json_build_object('id', u.id, 'name', u.name)
          ) as user,
          count(DISTINCT pn.*) filter (where pn.template_name = 'reminder') as reminder_count,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin
        from projects p
        join categories c on c.id = p.category_id
        join users u on u.id = p.user_id
        left join "1".project_totals pt on pt.project_id = p.id
        left join public.cities ct on ct.id = p.city_id
        left join public.states st on st.id = ct.state_id
        left join public.project_notifications pn on pn.project_id = p.id
        group by
          p.id,
          c.id,
          u.id,
          c.name_pt,
          ct.name,
          u.address_city,
          st.acronym,
          u.address_state,
          st.name,
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

      CREATE OR REPLACE VIEW "1".reward_details AS
       SELECT r.id,
          r.project_id,
          r.description,
          r.minimum_value,
          r.maximum_contributions,
          r.deliver_at,
          r.updated_at,
          public.paid_count(r.*) AS paid_count,
          public.waiting_payment_count(r.*) AS waiting_payment_count
         FROM public.rewards r
         order by r.row_order ASC;

      grant select on "1".reward_details to admin;
      grant select on "1".reward_details to web_user;
      grant select on "1".reward_details to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      drop view "1".project_details;
      create view "1".project_details as
        select
          p.id as project_id,
          coalesce(pt.progress, 0) as progress,
          coalesce(pt.pledged, 0) as pledged,
          coalesce(pt.total_contributions, 0) as total_contributions,
          p.state,
          p.expires_at,
          p.zone_expires_at,
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
          json_agg(DISTINCT rd.*) as rewards,
          count(DISTINCT pn.*) filter (where pn.template_name = 'reminder') as reminder_count
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

      CREATE OR REPLACE VIEW "1".reward_details AS
       SELECT r.id,
          r.project_id,
          r.description,
          r.minimum_value,
          r.maximum_contributions,
          r.deliver_at,
          r.updated_at,
          public.paid_count(r.*) AS paid_count,
          public.waiting_payment_count(r.*) AS waiting_payment_count
         FROM public.rewards r;

      grant select on "1".reward_details to admin;
      grant select on "1".reward_details to web_user;
      grant select on "1".reward_details to anonymous;
    SQL
  end
end
