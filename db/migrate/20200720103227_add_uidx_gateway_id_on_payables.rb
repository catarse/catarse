class AddUidxGatewayIdOnPayables < ActiveRecord::Migration
  def up
     execute <<-SQL
      create unique index uidx_gateway_id_gateway_payables on gateway_payables(gateway_id);
     SQL
  end

  def down
     execute <<-SQL
      drop index uidx_gateway_id_gateway_payables;
     SQL
  end
end
