class AddCancelingEnum < ActiveRecord::Migration
  def change
    execute <<-SQL
INSERT INTO pg_enum (enumtypid, enumlabel, enumsortorder)
SELECT 'payment_service.subscription_status'::regtype::oid, 'canceling', ( SELECT MAX(enumsortorder) + 1 FROM pg_enum WHERE enumtypid = 'payment_service.subscription_status'::regtype )
    SQL
  end
end
