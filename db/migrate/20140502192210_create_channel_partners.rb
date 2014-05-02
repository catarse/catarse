class CreateChannelPartners < ActiveRecord::Migration
  def change
    create_table :channel_partners do |t|
      t.text :name, null: false
      t.text :url, null: false
      t.text :image, null: false
      t.integer :channel_id, null: false

      t.timestamps
    end
  end
end
