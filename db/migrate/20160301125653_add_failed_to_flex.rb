class AddFailedToFlex < ActiveRecord::Migration[4.2]
  def change
    execute "INSERT INTO  flexible_project_states (state, state_order) VALUES ('failed', 'finished');"
  end
end
