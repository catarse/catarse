class ChangeColumnContribuniosPayerNameNull < ActiveRecord::Migration[4.2]
  def change
    change_column_null :contributions, :payer_name, true
  end
end
