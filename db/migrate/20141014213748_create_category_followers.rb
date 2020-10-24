class CreateCategoryFollowers < ActiveRecord::Migration[4.2]
  def change
    create_table :category_followers do |t|
      t.references :category, index: true, null: false
      t.references :user, index: true, null: false

      t.timestamps
    end
  end
end
