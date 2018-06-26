class CreateBlacklistDocuments < ActiveRecord::Migration
  def change
    create_table :blacklist_documents do |t|
      t.string :number, null: false

      t.timestamps null: false
    end
  end
end
