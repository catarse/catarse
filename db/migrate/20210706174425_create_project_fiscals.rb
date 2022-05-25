class CreateProjectFiscals < ActiveRecord::Migration[6.1]
  def change
    create_table :project_fiscals, id: :uuid do |t|
      t.references :user
      t.references :project
      t.monetize :total_amount
      t.monetize :total_catarse_fee
      t.monetize :total_gateway_fee
      t.monetize :total_antifraud_fee
      t.monetize :total_chargeback_cost
      t.jsonb :metadata, default: {}
      t.datetime :begin_date
      t.datetime :end_date

      t.timestamps
    end
  end
end