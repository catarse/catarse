class AddProjectTransitionsFk < ActiveRecord::Migration
  def up
    execute "SET statement_timeout TO 0"
    execute <<-SQL
    ALTER TABLE public.project_transitions ADD FOREIGN KEY (to_state) REFERENCES public.project_states (state);
    SQL
  end

  def down
    execute "SET statement_timeout TO 0"
    execute <<-SQL
    ALTER TABLE public.project_transitions DROP CONSTRAINT public.project_transitions_to_state_fkey;
    SQL
  end
end
