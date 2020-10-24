class AddCardCompanyAndTransactionTidIntoContributions < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :acquirer_name, :text
    add_column :contributions, :acquirer_tid, :text
  end
end
