class CreateFlexibleProjectStates < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE public.flexible_project_states (
      state text primary key,
      state_order project_state_order not null
    );
    ALTER TABLE public.flexible_projects ADD FOREIGN KEY (state) REFERENCES public.flexible_project_states (state);
    SQL
  end

  def down
    execute <<-SQL
    DROP TABLE public.flexible_project_states CASCADE;
    SQL
  end
end
