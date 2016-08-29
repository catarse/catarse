class AdjustFromNameAndEmailOnProjectInvitesDispatch < ActiveRecord::Migration
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
                    values ('project_invite', v_fallback_user_id, new.user_email, jsonb_build_object(
                        'associations', jsonb_build_object('project_invite_id', new.id, 'project_id', new.project_id),
                        'locale', 'pt',
                        'from_name', (split_part(trim(both ' ' from v_project_owner.name), ' ', 1)||' via '||settings('company_name')),
                        'from_email', v_project_owner.email
                    ), now());
            end if;

            return null;
        end;
    $function$

    }
  end
end
