class CreateCategoryFollowers < ActiveRecord::Migration
  def change
    create_table :category_followers do |t|
      t.references :category, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
