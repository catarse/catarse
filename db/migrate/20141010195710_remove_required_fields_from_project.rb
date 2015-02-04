class RemoveRequiredFieldsFromProject < ActiveRecord::Migration
  def change
    change_column_null :projects, :goal, true
    change_column_null :projects, :about, true
    change_column_null :projects, :headline, true
  end
end
