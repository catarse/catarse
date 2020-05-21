class CreateAntifraudAnalyses < ActiveRecord::Migration
  def change
    create_table :antifraud_analyses do |t|
      t.references :payment, foreign_key: true
      t.decimal :cost, null: false, default: 0.0
    end

    add_index :antifraud_analyses, :payment_id, unique: true
  end
end
