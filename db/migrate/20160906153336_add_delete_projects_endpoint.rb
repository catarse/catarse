class AddDeleteProjectsEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION "1".delete_project(_project_id integer) RETURNS void
          LANGUAGE plpgsql
          AS $$
              begin
                update project_transitions pt set most_recent = false where pt.project_id = _project_id;
                insert into public.project_transitions (to_state, metadata, sort_key, project_id, most_recent, created_at, updated_at) 
                values ('deleted', '{"to_state":"deleted", "from_state":' || (select p.state from projects p where id = _project_id) || '}', 0, _project_id, true, current_timestamp, current_timestamp);
                update projects set state = 'deleted' where id = _project_id;
              end;
            $$;

      grant execute on function "1".delete_project(integer) to admin, web_user;

      grant insert, select, update on public.project_transitions to admin;
      grant insert, select, update on public.project_transitions to web_user;
      grant update on public.projects to admin;
      grant update on public.projects to web_user;
    SQL
  end
end
