class CreateContributionsPayments < ActiveRecord::Migration
  def change
    create_table :contributions_payments do |t|
      t.integer :contribution_id, null: false
      t.integer :payment_id, null: false
    end

    add_index :contributions_payments, [:contribution_id, :payment_id], unique: true
  end
end
