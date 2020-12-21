class SurveyConstraint < ActiveRecord::Migration[4.2]
  def change
    execute "ALTER TABLE surveys ADD UNIQUE (reward_id);"
  end
end
