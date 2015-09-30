class CreateDonatedContributions < ActiveRecord::Migration
  def change
    create_table :donated_contributions do |t|
      t.references :contribution, null: false

      t.timestamps
    end
  end
end
