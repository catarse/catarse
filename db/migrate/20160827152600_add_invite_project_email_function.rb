class AddInviteProjectEmailFunction < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function "1".invite_project_email(data json)
    returns void
    VOLATILE
    language plpgsql
    as $$
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
                if not exists (select true from public.project_invites where project_id = v_project.id and user_email = email) then
                    insert into public.project_invites(project_id, user_email, created_at) values (v_project.id, email, now());
                end if;
            end loop;

        end;
    $$;

grant select on public.project_invites to admin, web_user;
grant insert on public.project_invites to admin, web_user;
grant execute on function "1".invite_project_email(json) to admin, web_user;
grant usage on SEQUENCE public.project_invites_id_seq to admin, web_user;
    }
  end

  def down
    execute %Q{
DROP FUNCTION "1".invite_project_email(json);
    }
  end
end
