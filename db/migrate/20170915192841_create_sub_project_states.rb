class CreateSubProjectStates < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    CREATE TABLE public.subscription_project_states (
      state text primary key,
      state_order project_state_order not null
    );

    grant select on subscription_project_states to admin, web_user, anonymous;

    INSERT INTO public.subscription_project_states (state, state_order) VALUES
    ('deleted', 'archived'),
    ('draft', 'created'),
    ('online', 'published');


    CREATE OR REPLACE FUNCTION state_order(project_id integer) RETURNS project_state_order
        LANGUAGE sql STABLE
        AS $_$
    SELECT
    CASE p.mode
    WHEN 'flex' THEN
        (
        SELECT state_order
        FROM
        public.project_states ps
        WHERE
        ps.state = p.state
        )
    WHEN 'sub' THEN
        (
        SELECT state_order
        FROM
        public.subscription_project_states ps
        WHERE
        ps.state = p.state
        )
    ELSE
        (
        SELECT state_order
        FROM
        public.project_states ps
        WHERE
        ps.state = p.state
        )
    END
    FROM public.projects p
    WHERE p.id = $1;
    $_$;
    SQL
  end
end
