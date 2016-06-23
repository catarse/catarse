class AddTriggerToRdstationFirstWeekGoal < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE FUNCTION notify_about_confirmed_payments() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        declare
          v_contribution json;
          v_project public.projects;
          v_p_total "1".project_totals;
        begin
          v_contribution := (select
              json_build_object(
                'user_image', u.thumbnail_image,
                'user_name', u.name,
                'project_image', p.thumbnail_image,
                'project_name', p.name)
              from contributions c
              join users u on u.id = c.user_id
              join projects p on p.id = c.project_id
              where not c.anonymous and c.id = new.contribution_id);

          if v_contribution is not null then
            perform pg_notify('new_paid_contributions', v_contribution::text);
          end if;
          

          SELECT p.* FROM contributions c
          JOIN projects p ON p.id= c.project_id 
          where c.id = NEW.contribution_id INTO v_project;
          
          SELECT * FROM "1".project_totals WHERE project_id = v_project.id INTO v_p_total;
          
          IF public.online_at(v_project) + '7 days'::interval >= now() THEN
            IF ((v_p_total.paid_pledged / v_project.goal) * (100)::numeric) >= 10 AND NOT EXISTS (
                SELECT TRUE FROM public.rdevents WHERE user_id = v_project.user_id AND project_id = v_project.id AND event_name = 'project_first_week_goal') THEN
                INSERT INTO public.rdevents(event_name, user_id, project_id, metadata) VALUES ('project_first_week_goal', v_project.user_id, v_project.id, json_build_object(
                    'contribution_id', NEW.contribution_id
                ));
            END IF;
          END IF;

          return null;
        end;
      $$;

    }
  end

  def down
    execute %{
CREATE OR REPLACE FUNCTION notify_about_confirmed_payments() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        declare
          v_contribution json;
        begin
          v_contribution := (select
              json_build_object(
                'user_image', u.thumbnail_image,
                'user_name', u.name,
                'project_image', p.thumbnail_image,
                'project_name', p.name)
              from contributions c
              join users u on u.id = c.user_id
              join projects p on p.id = c.project_id
              where not c.anonymous and c.id = new.contribution_id);

          if v_contribution is not null then
            perform pg_notify('new_paid_contributions', v_contribution::text);
          end if;

          return null;
        end;
      $$;

    }
  end
end
