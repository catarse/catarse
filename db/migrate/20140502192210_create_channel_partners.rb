class CreateChannelPartners < ActiveRecord::Migration
  def change
    create_table :channel_partners do |t|
      t.text :name
      t.text :url
      t.text :image
      t.integer :channel_id

      t.timestamps
    end
  end
end
