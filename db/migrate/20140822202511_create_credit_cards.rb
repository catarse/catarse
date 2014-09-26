class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.references :user, index: true
      t.text :last_digits, null: false
      t.text :card_brand, null: false
      t.text :object_id, foreign_key: false, null: false

      t.timestamps
    end
  end
end
