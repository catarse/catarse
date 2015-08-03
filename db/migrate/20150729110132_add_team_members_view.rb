class AddTeamMembersView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE ROLE anonymous NOLOGIN;
      CREATE OR REPLACE FUNCTION was_confirmed(contributions) RETURNS boolean
          LANGUAGE sql STABLE SECURITY DEFINER
          AS $_$
            SELECT EXISTS (
              SELECT true
              FROM
                payments p
              WHERE p.contribution_id = $1.id AND p.state = ANY(confirmed_states())
            );
          $_$;

      CREATE OR REPLACE FUNCTION public.profile_img_thumbnail(users) RETURNS text AS $$
      SELECT
        'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
        '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
        '/uploads/user/uploaded_image/' || $1.id::text ||
        '/thumb_avatar_' || $1.uploaded_image
      $$ LANGUAGE SQL STABLE SECURITY DEFINER;

      CREATE OR REPLACE VIEW "1".team_members AS (
        select
          u.id,
          u.name,
          u.profile_img_thumbnail as img,
          COALESCE(ut.total_contributed_projects, 0) as total_contributed_projects,
          COALESCE(ut.sum, 0) as total_amount_contributed
        from users u
        left join "1".user_totals ut on ut.user_id = u.id
        where u.admin
        order by u.name asc
      );

      GRANT SELECT on "1".team_members to admin;
      GRANT SELECT on "1".team_members to web_user;
      GRANT SELECT on "1".team_members to anonymous;

      drop index if exists user_totals_user_id_ix;
      drop index if exists user_admin_id_ix;
      create index user_totals_user_id_ix on "1".user_totals(user_id);
      create index user_admin_id_ix on users(id) where admin;

      CREATE OR REPLACE VIEW "1".team_totals as (
        select
          count(DISTINCT u.id) as member_count,
          array_to_json(array_agg(DISTINCT country.name)) as countries,
          count(DISTINCT c.project_id)
            FILTER (WHERE c.was_confirmed)
            as total_contributed_projects,
          count(DISTINCT lower(unaccent(u.address_city))) as total_cities,
          sum(c.value)
            FILTER (WHERE c.was_confirmed)
            as total_amount
        from users u
        left join contributions c on c.user_id = u.id
        left join countries country on country.id = u.country_id
        where u.admin
      );

      GRANT SELECT on "1".team_totals to admin;
      GRANT SELECT on "1".team_totals to web_user;
      GRANT SELECT on "1".team_totals to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      DROP ROLE anonymous NOLOGIN;
      drop view "1".team_members;
      drop view if exists "1".team_totals;
      drop index if exists user_totals_user_id_ix;
      drop index if exists user_admin_id_ix;

      CREATE OR REPLACE FUNCTION was_confirmed(contributions) RETURNS boolean
          LANGUAGE sql
          AS $_$
            SELECT EXISTS (
              SELECT true
              FROM
                payments p
              WHERE p.contribution_id = $1.id AND p.state = ANY(confirmed_states())
            );
          $_$;

      CREATE OR REPLACE FUNCTION public.profile_img_thumbnail(users) RETURNS text AS $$
      SELECT
        'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
        '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
        '/uploads/user/uploaded_image/' || $1.id::text ||
        '/thumb_avatar_' || $1.uploaded_image
      $$ LANGUAGE SQL STABLE;
    SQL
  end
end
