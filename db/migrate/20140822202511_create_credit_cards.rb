class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.references :user, index: true
      t.text :last_digits
      t.text :card_brand
      t.text :object_id, foreign_key: false

      t.timestamps
    end
  end
end
