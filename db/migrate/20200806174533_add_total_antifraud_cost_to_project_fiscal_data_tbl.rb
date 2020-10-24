class AddTotalAntifraudCostToProjectFiscalDataTbl < ActiveRecord::Migration[4.2]
  def change
    add_column :project_fiscal_data_tbl, :total_antifraud_cost, :decimal, default: 0, precision: 8, scale: 2
  end
end
