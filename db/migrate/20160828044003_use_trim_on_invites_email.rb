class UseTrimOnInvitesEmail < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE FUNCTION "1".invite_project_email(data json)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
        declare
            v_project public.projects;
            email text;
        begin

            select * from public.projects where id = (data->>'project_id')::integer into v_project;

            if (data->>'project_id')::integer is null or not public.is_owner_or_admin(v_project.user_id) then
                raise exception 'invalid project permission';
            end if;

            for email in select * from json_array_elements((data->>'emails')::json)
            loop
                if not exists (select true from public.project_invites where project_id = v_project.id and user_email = trim(both '"' from email)) then
                    insert into public.project_invites(project_id, user_email, created_at) values (v_project.id, trim(both '"' from email), now());
                end if;
            end loop;

        end;
    $function$

    }
  end
end
