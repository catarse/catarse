class AddFlexibleProjectTransitionsFk < ActiveRecord::Migration
  def up
    execute "SET statement_timeout TO 0"
    execute <<-SQL
    ALTER TABLE public.flexible_project_transitions ADD FOREIGN KEY (to_state) REFERENCES public.flexible_project_states (state);
    SQL
  end

  def down
    execute "SET statement_timeout TO 0"
    execute <<-SQL
    ALTER TABLE public.flexible_project_transitions DROP CONSTRAINT public.flexible_project_transitions_to_state_fkey;
    SQL
  end
end
