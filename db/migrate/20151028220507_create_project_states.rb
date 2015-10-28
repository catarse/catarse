class CreateProjectStates < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TYPE public.project_state_order AS ENUM ('deleted', 'visible', 'publishable', 'published', 'finished');
    CREATE TABLE public.project_states (
      state text primary key,
      state_order project_state_order not null
    );
    INSERT INTO public.project_states (state, state_order) VALUES
    ('deleted', 'deleted'),
    ('rejected', 'visible'),
    ('draft', 'visible'),
    ('in_analysis', 'visible'),
    ('approved', 'publishable'),
    ('online', 'published'),
    ('waiting_funds', 'published'),
    ('failed', 'finished'),
    ('successful', 'finished');
    ALTER TABLE public.projects ADD FOREIGN KEY (state) REFERENCES public.project_states (state);
    SQL
  end

  def down
    execute <<-SQL
    DROP TABLE public.project_states;
    DROP TYPE public.project_state_order;
    SQL
  end
end
