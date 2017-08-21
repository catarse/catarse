class SurveyConstraint < ActiveRecord::Migration
  def change
    execute "ALTER TABLE surveys ADD UNIQUE (reward_id);"
  end
end
