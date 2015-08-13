class CreateUniqueIndexForPaymentsGatewayId < ActiveRecord::Migration
  def up
    execute "
    DROP INDEX IF EXISTS payments_gateway_id_gateway_idx;
    CREATE UNIQUE INDEX ON payments (gateway_id, gateway);
    "
  end

  def down
    execute "DROP INDEX IF EXISTS payments_gateway_id_gateway_idx"
  end
end
