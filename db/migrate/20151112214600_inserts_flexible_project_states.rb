class InsertsFlexibleProjectStates < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    INSERT INTO public.flexible_project_states (state, state_order) VALUES
    ('deleted', 'archived'),
    ('rejected', 'created'),
    ('draft', 'created'),
    ('online', 'published'),
    ('waiting_funds', 'published'),
    ('successful', 'finished');
    SQL
  end
end
