class SetNotNullColumnsOnProjectFiscals < ActiveRecord::Migration[6.1]
  def change
    change_column_null :project_fiscals, :user_id, true
    change_column_null :project_fiscals, :project_id, true
    change_column_null :project_fiscals, :begin_date, true
    change_column_null :project_fiscals, :end_date, true
  end
end
