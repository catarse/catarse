class ChangeColumnContribuniosPayerNameNull < ActiveRecord::Migration
  def change
    change_column_null :contributions, :payer_name, true
  end
end
