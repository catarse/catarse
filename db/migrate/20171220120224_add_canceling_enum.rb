class AddCancelingEnum < ActiveRecord::Migration[4.2]
  def change
    # for deploy on RDS run alter enum directly on console, since it can't be run inside a transaction
    # need to think of a better way to solve this
    if Rails.env.development?
      execute <<-SQL
      INSERT INTO pg_enum (enumtypid, enumlabel, enumsortorder)
      SELECT 'payment_service.subscription_status'::regtype::oid, 'canceling', ( SELECT MAX(enumsortorder) + 1 FROM pg_enum WHERE enumtypid = 'payment_service.subscription_status'::regtype )
      SQL
    end
  end
end
