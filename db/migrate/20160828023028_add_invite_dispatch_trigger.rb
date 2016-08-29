class AddInviteDispatchTrigger < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.project_invite_dispatch() returns trigger
    language plpgsql
    as $$
        declare
            v_project public.projects;
            v_fallback_user_id integer;
        begin
            select * from public.projects where id = new.project_id into v_project;

            if public.open_for_contributions(v_project) then
                select id from users where email = new.user_email into v_fallback_user_id;

                insert into public.notifications(template_name, user_id, user_email, metadata, created_at) 
                    values ('project_invite', v_fallback_user_id, new.user_email, jsonb_build_object(
                        'associations', jsonb_build_object('project_invite_id', new.id, 'project_id', new.project_id),
                        'locale', 'pt',
                        'from_name', settings('company_name'),
                        'from_email', settings('email_contact')
                    ), now());
            end if;

grant insert on public.notifications to admin, web_user;
grant usage on sequence notifications_id_seq to admin, web_user

            return null;
        end;
    $$;

CREATE TRIGGER project_invite_dispatch AFTER INSERT ON public.project_invites FOR EACH ROW EXECUTE PROCEDURE public.project_invite_dispatch();
    }
  end

  def down
    execute %Q{
drop function public.project_invite_dispatch() cascade;
    }
  end
end
