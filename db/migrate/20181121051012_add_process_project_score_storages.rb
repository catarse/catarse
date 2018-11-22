class AddProcessProjectScoreStorages < ActiveRecord::Migration
  def up
    execute <<-SQL
create or replace function public.refresh_project_score_storage(public.projects) returns numeric
language plpgsql VOLATILE 
as $$
    declare
        v_score numeric;
    begin
        v_score := coalesce(public.score($1), 0);

        begin
            insert into public.project_score_storages (project_id, score, refreshed_at)
                values ($1.id, v_score, now());
        exception when unique_violation then
            update public.project_score_storages
                set score = v_score,
                    refreshed_at = now()
                where project_id = $1.id;
        end;

        return v_score;
    end;
$$;

create or replace function public.refresh_all_online_project_score_storages() returns void
language plpgsql volatile
as $$
    declare
        v_project public.projects;
        v_score numeric;
    begin
        for v_project in (select * from public.projects where state = 'online') 
        loop
            v_score := public.refresh_project_score_storage(v_project);
            raise notice 'performed on project id % with score %', v_project.id, v_score;
        end loop;
        return;
    end;
$$;

    SQL
  end

  def down
    execute <<-SQL
      drop function public.refresh_all_online_project_score_storages();
      drop function public.refresh_project_score_storage(public.projects);
    SQL
  end
end
