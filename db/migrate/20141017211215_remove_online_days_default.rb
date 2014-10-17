class RemoveOnlineDaysDefault < ActiveRecord::Migration
  def change
    change_column_default(:projects, :online_days, nil)
  end
end
