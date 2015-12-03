class CreateOrigins < ActiveRecord::Migration
  def change
    create_table :origins do |t|
      t.text :domain, null: false
      t.text :referral

      t.timestamps
    end

    add_index :origins, [:domain, :referral], unique: true

    add_column :projects, :origin_id, :integer
    add_column :contributions, :origin_id, :integer
  end
end
