class CreateLoginActivities < ActiveRecord::Migration[4.2]
  def change
    create_table :login_activities do |t|
      t.string :ip_address, null: false
      t.references :user, index: true, null: false

      t.timestamps
    end
  end
end
