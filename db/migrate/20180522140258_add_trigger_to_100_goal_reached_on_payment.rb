class AddTriggerTo100GoalReachedOnPayment < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.rdevent_100_goal_reached() 
returns trigger 
language plpgsql
as $$
    begin
        -- when project is online and reached the goal 
        if not exists(
            select true from rdevents r
                join projects p on p.id = r.project_id
                join contributions c on c.project_id = p.id and c.id = NEW.contribution_id
                where p.id = c.project_id and c.id = NEW.contribution_id
                    and r.event_name = '100_goal_reached'
        ) and exists (
            select true 
            from projects p
            join contributions c on c.project_id = p.id and c.id = NEW.contribution_id
            left join "1".project_totals pt on pt.project_id = p.id
            where c.id = NEW.contribution_id
                and pt.progress >= 100
                and p.state = 'online'
                and p.id = c.project_id
        ) then
            begin
            insert into public.rdevents(project_id, user_id, event_name, metadata)
                (
                    select
                        p.id as project_id,
                        p.user_id as user_id,
                        '100_goal_reached' as event_name,
                        row_to_json(pt.*) as metadata
                    from projects p
                    join contributions c on c.project_id = p.id and c.id = NEW.contribution_id
                    join "1".project_totals pt on pt.project_id = p.id
                    where c.id = NEW.contribution_id and p.id = c.project_id
                );
            EXCEPTION WHEN unique_violation THEN
            end;
        end if;

        return NEW;
    end;
$$;

create unique index uidx_rdevents_100_goal_reached_idx on rdevents (project_id, event_name) where event_name = '100_goal_reached';
CREATE TRIGGER rdevent_100_goal_reached 
AFTER UPDATE OF state ON public.payments 
FOR EACH ROW WHEN (((old.state <> 'paid'::text) AND (new.state = 'paid'::text))) 
EXECUTE PROCEDURE rdevent_100_goal_reached();
}
  end

  def down
    execute %Q{
drop trigger rdevent_100_goal_reached on payments;
drop function public.rdevent_100_goal_reached();
drop index uidx_rdevents_100_goal_reached_idx;
}
  end
end
