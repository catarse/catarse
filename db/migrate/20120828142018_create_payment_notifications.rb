class CreatePaymentNotifications < ActiveRecord::Migration
  def up
    execute <<-PSQL
      CREATE EXTENSION hstore;
    PSQL

    create_table :payment_notifications do |t|
      t.integer :backer_id, null: false
      t.text :status, null: false
      t.hstore :extra_data

      t.timestamps
    end
  end

  def down
    execute <<-PSQL
      DROP EXTENSION hstore;
    PSQL

    drop_table :payment_notificaitons
  end
end
