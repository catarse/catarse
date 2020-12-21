class CreateCities < ActiveRecord::Migration[4.2]
  def change
    create_table :cities do |t|
      t.text     :name, null: false
      t.integer  :state_id, null: false
    end
  end
end
