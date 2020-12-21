class ChangeNullOnAgencyDigit < ActiveRecord::Migration[4.2]
  def change
    change_column_null :bank_accounts, :agency_digit, true
  end
end
