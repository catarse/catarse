class MovePaymentLogsToPaymentNotifications < ActiveRecord::Migration
  def up
    execute <<SQL
    INSERT INTO payment_notifications (backer_id, status, extra_data, created_at, updated_at)
    SELECT 
      backer_id,
      CASE payment_status
        WHEN 1 THEN 'confirmed'
        WHEN 4 THEN 'confirmed'
        ELSE 'pending'
      END as status,
      '{"amount":' || coalesce('"' || amount || '"', 'null') || ',' ||
      '"payment_status":' || coalesce('"' || payment_status || '"', 'null') || ',' ||
      '"moip_id":' || coalesce('"' || moip_id || '"', 'null') || ',' ||
      '"payment_method":' || coalesce('"' || payment_method || '"', 'null') || ',' ||
      '"payment_type":' || coalesce('"' || payment_type || '"', 'null') || ',' ||
      '"consumer_email":' || coalesce('"' || consumer_email || '"', 'null') || '}' as extra_data,
      created_at,
      updated_at
    FROM payment_logs;
SQL
  end

  def down
  end
end
