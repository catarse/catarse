class FixesJsonbBuildObject < ActiveRecord::Migration
  def change
    execute %Q{
    CREATE OR REPLACE FUNCTION public.project_invite_dispatch()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        declare
            v_project public.projects;
            v_fallback_user_id integer;
            v_project_owner public.users;
        begin
            select * from public.projects where id = new.project_id into v_project;
            select * from public.users where id = v_project.user_id into v_project_owner;

            if public.open_for_contributions(v_project) then
                select id from users where email = new.user_email into v_fallback_user_id;

                insert into public.notifications(template_name, user_id, user_email, metadata, created_at) 
                    values ('project_invite', v_fallback_user_id, new.user_email, json_build_object(
                        'associations', json_build_object('project_invite_id', new.id, 'project_id', new.project_id),
                        'locale', 'pt',
                        'from_name', (split_part(trim(both ' ' from v_project_owner.name), ' ', 1)||' via '||settings('company_name')),
                        'from_email', v_project_owner.email
                    )::jsonb, now());
            end if;

            return null;
        end;
    $function$;

CREATE OR REPLACE VIEW "1"."projects" AS 
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    p.mode,
    (p.state)::text AS state,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT
                CASE
                    WHEN ((p.state)::text = 'failed'::text) THEN pt.pledged
                    ELSE pt.paid_pledged
                END AS paid_pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
    elapsed_time_json(p.*) AS elapsed_time,
    score(p.*) AS score,
    (EXISTS ( SELECT true AS bool
           FROM (contributions c_1
             JOIN user_follows uf ON ((uf.follow_id = c_1.user_id)))
          WHERE ((is_confirmed(c_1.*) AND (uf.user_id = current_user_id())) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
    p.user_id AS project_user_id,
    p.video_embed_url as video_embed_url
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     JOIN public.cities c ON ((c.id = p.city_id)))
     JOIN public.states s ON ((s.id = c.state_id)))
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
     JOIN LATERAL state_order(p.*) so(so) ON (true));
    }
  end
end
