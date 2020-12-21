class CreateBlacklistDocuments < ActiveRecord::Migration[4.2]
  def change
    create_table :blacklist_documents do |t|
      t.string :number, null: false

      t.timestamps null: false
    end
  end
end
