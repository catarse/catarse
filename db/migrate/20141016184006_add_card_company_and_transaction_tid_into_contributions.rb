class AddCardCompanyAndTransactionTidIntoContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :acquirer_name, :text
    add_column :contributions, :acquirer_tid, :text
  end
end
