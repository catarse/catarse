class ChangeTotalAmountAndAddTotalIrrfOnProjectFiscals < ActiveRecord::Migration[6.1]
  def change
    add_monetize :project_fiscals, :total_irrf
    add_monetize :project_fiscals, :total_amount_to_pj
    add_monetize :project_fiscals, :total_amount_to_pf
    remove_monetize :project_fiscals, :total_amount
  end
end
