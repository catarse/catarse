class MigrateContributionsDataToPayments < ActiveRecord::Migration
  def up
    execute "
    INSERT INTO payments (
      state,
      key,
      gateway,
      gateway_id,
      gateway_fee,
      geteway_data,
      method,
      value,
      installments,
      installment_value,
      created_at,
      updated_at
    )
    "
  end

  def down
    execute "TRUNCATE TABLE payments;"
  end
end
