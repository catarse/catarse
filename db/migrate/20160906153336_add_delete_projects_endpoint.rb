class AddDeleteProjectsEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
        CREATE OR REPLACE VIEW "1".project_transitions AS
          SELECT project_transitions.project_id,
          project_transitions.to_state AS state,
          project_transitions.metadata,
          project_transitions.most_recent,
          project_transitions.created_at
           FROM project_transitions
           join projects p on p.id = project_transitions.project_id
          WHERE is_owner_or_admin(p.user_id);

      CREATE OR REPLACE FUNCTION set_project_state() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              begin
                update project_transitions pt set most_recent = false where pt.project_id = NEW.project_id;
                insert into public.project_transitions (to_state, metadata, sort_key, project_id, most_recent, created_at, updated_at) 
                values (NEW.STATE, '{"to_state":' || NEW.state || ',"from_state":' || (select p.state from projects p where id = NEW.project_id) || '}', 0, NEW.project_id, true, current_timestamp, current_timestamp);
                update projects set state = NEW.state where id = NEW.project_id;
                return new;
              end;
            $$;


      create trigger set_project_state instead of insert on "1".project_transitions
        for each row execute procedure public.set_project_state();

      grant insert, select, update on "1".project_transitions to web_user;
      grant insert, select, update on "1".project_transitions to admin;
      grant insert, select, update on public.project_transitions to admin;
      grant insert, select, update on public.project_transitions to web_user;
      grant usage on sequence project_transitions_id_seq to web_user;
      grant usage on sequence project_transitions_id_seq to admin;
      grant update on public.projects to admin;
      grant update on public.projects to web_user;
    SQL
  end
end
