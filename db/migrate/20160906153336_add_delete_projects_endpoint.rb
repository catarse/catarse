class AddDeleteProjectsEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL

    CREATE OR REPLACE FUNCTION public.generate_project_full_text_index(project public.projects) RETURNS tsvector
    LANGUAGE plpgsql
    STABLE
    AS $$
        DECLARE
            full_text_index tsvector;
        BEGIN

            full_text_index :=  setweight(to_tsvector('portuguese', unaccent(coalesce(project.name::text, ''))), 'A') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce(project.permalink::text, ''))), 'C') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce(project.headline::text, ''))), 'B') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT c.name_pt FROM categories c WHERE c.id = project.category_id)::text, ''))), 'B') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce((select array_agg(t.name)::text from public.taggings ta join public_tags t on t.id = ta.public_tag_id where ta.project_id = project.id)::text, ''))), 'B') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT u.name FROM users u WHERE u.id = project.user_id)::text, ''))), 'C');

          RETURN full_text_index;
        END
    $$;

    CREATE OR REPLACE FUNCTION update_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      if NEW.state NOT IN ('draft', 'deleted') then
        new.full_text_index :=  public.generate_project_full_text_index(NEW);
      end if;
      RETURN NEW;
    END;
    $$;



      CREATE OR REPLACE FUNCTION "1".delete_project(_project_id integer) RETURNS void
          LANGUAGE plpgsql
          AS $$
            declare
                v_project public.projects;
            begin
                select * from public.projects where id = _project_id into v_project;

                if _project_id is null or not public.is_owner_or_admin(v_project.user_id) or v_project.state <> 'draft' then
                    raise exception 'invalid project permission';
                end if;

                update project_transitions pt set most_recent = false where pt.project_id = _project_id;
                insert into public.project_transitions (to_state, metadata, sort_key, project_id, most_recent, created_at, updated_at) 
                values ('deleted', '{"to_state":"deleted", "from_state":' || v_project.state || '}', 0, _project_id, true, current_timestamp, current_timestamp);
                update projects set state = 'deleted', permalink = ('_deleted_' || _project_id) where id = _project_id;
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
