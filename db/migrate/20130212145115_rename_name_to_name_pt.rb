class RenameNameToNamePt < ActiveRecord::Migration[4.2]
  def change
   rename_column :categories, :name, :name_pt
  end
end
