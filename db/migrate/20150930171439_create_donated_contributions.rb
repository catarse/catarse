class CreateDonatedContributions < ActiveRecord::Migration[4.2]
  def change
    create_table :donations do |t|
      t.timestamps
    end
  end
end
