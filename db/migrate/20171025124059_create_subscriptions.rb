class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :project, index: true, foreign_key: true, null: false
      t.bigint :gateway_subscription_id, foreign_key: false, unique: true, null: false
      t.string :status, null: false
      t.decimal :amount, null: false
      t.references :reward, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
