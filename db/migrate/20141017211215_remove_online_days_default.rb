class RemoveOnlineDaysDefault < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:projects, :online_days, nil)
  end
end
