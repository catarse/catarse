class CreateBannedIps < ActiveRecord::Migration[4.2]
  def change
    create_table :banned_ips do |t|
      t.text :ip, null: false

      t.timestamps
    end
  end
end
