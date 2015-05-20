class AddNameFrToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :name_fr, :string
  end
end
