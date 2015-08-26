class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.text     :name, null: false
      t.integer  :state_id, null: false
    end
  end
end
