class RenameNameToNamePt < ActiveRecord::Migration
  def change
   rename_column :categories, :name, :name_en
  end
end
