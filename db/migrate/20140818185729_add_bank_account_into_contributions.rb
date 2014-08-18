class AddBankAccountIntoContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :bank_account_id, :integer
  end
end
