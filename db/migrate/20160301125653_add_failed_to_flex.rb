class AddFailedToFlex < ActiveRecord::Migration
  def change
    execute "INSERT INTO  flexible_project_states (state, state_order) VALUES ('failed', 'finished');"
  end
end
