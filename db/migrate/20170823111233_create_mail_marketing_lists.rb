class CreateMailMarketingLists < ActiveRecord::Migration
  def change
    create_table :mail_marketing_lists do |t|
      t.string :provider, null: false
      t.string :label, null: false
      t.string :list_id, null: false, foreign_key: false

      t.timestamps null: false
    end

    add_index :mail_marketing_lists, [:provider, :list_id], unique: true
    add_index :mail_marketing_lists, [:provider, :label], unique: true
  end
end
