class AddsIndexToGatewayPaymentsTransactionid < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE INDEX idx_transactionid_gp
    ON public.gateway_payments
     USING btree
     (transaction_id COLLATE pg_catalog."default");
    SQL
  end

  def down
    execute <<-SQL
    DROP INDEX idx_transactionid_gp;
    SQL
  end
end
