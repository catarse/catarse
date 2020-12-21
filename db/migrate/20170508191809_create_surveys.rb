class CreateSurveys < ActiveRecord::Migration[4.2]
  def change
    create_table :surveys do |t|
      t.references :reward, null: false
      t.boolean :confirm_address
      t.timestamp :sent_at
      t.timestamp :finished_at

      t.timestamps
    end
  end
end
