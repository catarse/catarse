class AddNameEnToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :name_en, :string
  end
end
