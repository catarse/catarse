class CreateDonatedContributions < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.timestamps
    end
  end
end
