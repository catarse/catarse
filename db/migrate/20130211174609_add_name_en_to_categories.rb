class AddNameEnToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :name_en, :string
  end
end
