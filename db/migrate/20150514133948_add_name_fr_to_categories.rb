class AddNameFrToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :name_fr, :string
  end
end
