class ChangeNullOnAgencyDigit < ActiveRecord::Migration
  def change
    change_column_null :bank_accounts, :agency_digit, true
  end
end
