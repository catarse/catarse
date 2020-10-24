class ChangeMaxInstallmentsTo6 < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
      update projects set total_installments = 6 where total_installments = 3;
    SQL
  end
end
