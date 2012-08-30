class MovePaymentDetailsToPaymentNotifications < ActiveRecord::Migration
  def up
    execute <<SQL
    UPDATE payment_details 
    SET 
      backer_id = (
                    SELECT max(b.id) 
                    FROM payment_details pd 
                      JOIN users u ON (pd.payer_email = u.email) 
                      JOIN backers b ON b.user_id = u.id AND b.value = pd.total_amount AND b.created_at::date = pd.created_at::date 
                    WHERE pd.backer_id IS NULL AND pd.id = payment_details.id
                    HAVING count(distinct u.id) = 1
                  )
    WHERE backer_id IS NULL;
    INSERT INTO payment_notifications (backer_id, status, extra_data, created_at, updated_at)
    SELECT
      backer_id,
      CASE payment_status
        WHEN 'Concluido' THEN 'confirmed'
        WHEN 'Autorizado' THEN 'confirmed'
        ELSE 'pending'
      END as status,
      '{"payer_name":' || coalesce('"' || replace(replace(payer_name::text, '\\', ''), '"', '\\"') || '"', 'null') || ',' ||
      '"payer_email":' || coalesce('"' || replace(payer_email::text, '"', '\\"') || '"', 'null') || ',' ||
      '"city":' || coalesce('"' || replace(city::text, '"', '\\"') || '"', 'null') || ',' ||
      '"uf":' || coalesce('"' || replace(uf::text, '"', '\\"') || '"', 'null') || ',' ||
      '"payment_method":' || coalesce('"' || replace(payment_method::text, '"', '\\"') || '"', 'null') || ',' ||
      '"net_amount":' || coalesce('"' || replace(net_amount::text, '"', '\\"') || '"', 'null') || ',' ||
      '"total_amount":' || coalesce('"' || replace(total_amount::text, '"', '\\"') || '"', 'null') || ',' ||
      '"service_tax_amount":' || coalesce('"' || replace(service_tax_amount::text, '"', '\\"') || '"', 'null') || ',' ||
      '"backer_amount_tax":' || coalesce('"' || replace(backer_amount_tax::text, '"', '\\"') || '"', 'null') || ',' ||
      '"payment_status":' || coalesce('"' || replace(regexp_replace(payment_status::text, '.*Tipo.*', ''), '"', '\\"') || '"', 'null') || ',' ||
      '"service_code":' || coalesce('"' || replace(service_code::text, '"', '\\"') || '"', 'null') || ',' ||
      '"institution_of_payment":' || coalesce('"' || replace(institution_of_payment::text, '"', '\\"') || '"', 'null') || ',' ||
      '"payment_date":' || coalesce('"' || replace(payment_date::text, '"', '\\"') || '"', 'null') || '}' as extra_data,
      created_at,
      updated_at
    FROM payment_details 
    WHERE backer_id IS NOT NULL;
SQL
  end

  def down
  end
end
