class AddCancelProject < ActiveRecord::Migration
  def change
    execute <<-SQL

      CREATE OR REPLACE FUNCTION "1".cancel_project(_project_id integer) RETURNS void
          LANGUAGE plpgsql
          AS $$
            declare
                v_project public.projects;
            begin
                select * from public.projects where id = _project_id into v_project;

                if _project_id is null or not public.is_owner_or_admin(v_project.user_id) or v_project.state <> 'online' then
                    raise exception 'invalid project permission';
                end if;

                update project_transitions pt set most_recent = false where pt.project_id = _project_id;
                insert into public.project_transitions (to_state, metadata, sort_key, project_id, most_recent, created_at, updated_at) 
                values ('failed', '{"to_state":"failed", "from_state":' || v_project.state || '}', 30, _project_id, true, current_timestamp, current_timestamp);
                update projects set state = 'failed' where id = _project_id;
              end;
            $$;

      grant execute on function "1".cancel_project(integer) to admin, web_user;
      grant ALL  on rdevents to admin, web_user;
      grant all on sequence rdevents_id_seq to admin, web_user;

    SQL
  end
end
