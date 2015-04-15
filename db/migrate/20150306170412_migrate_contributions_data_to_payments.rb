class MigrateContributionsDataToPayments < ActiveRecord::Migration
  def up
    execute <<-SQL
    INSERT INTO payments (
      id,
      contribution_id,
      state,
      key,
      gateway,
      gateway_id,
      gateway_fee,
      gateway_data,
      payment_method,
      value,
      installments,
      installment_value,
      created_at,
      updated_at,
      paid_at,
      refused_at,
      pending_refund_at,
      refunded_at
    )
    SELECT
      c.id,
      c.id,
      CASE c.state
        WHEN 'pending' THEN 'pending'
        WHEN 'waiting_confirmation' THEN 'pending'
        WHEN 'refunded' THEN 'refunded'
        WHEN 'refunded_and_canceled' THEN 'deleted'
        WHEN 'requested_refund' THEN 'pending_refund'
        WHEN 'requested_refund' THEN 'pending_refund'
        WHEN 'canceled' THEN 'refused'
        WHEN 'invalid_payment' THEN 'refused'
        WHEN 'confirmed' THEN 'paid'
        WHEN 'chargeback' THEN 'chargeback'
        ELSE c.state
      END,
      coalesce(c.key, md5(id::text || current_timestamp::text)),
      CASE 
        WHEN c.credits THEN 'Credits'
        WHEN c.payment_method = 'Credits' THEN 'Credits'
        WHEN c.payment_method = 'PayPal' THEN 'PayPal'
        WHEN c.payment_method = 'Pagarme' THEN 'Pagarme'
        ELSE 'MoIP'
      END,
      c.payment_id,
      c.payment_service_fee,
      '{}',
      CASE
        WHEN c.credits OR c.payment_method = 'Credits' THEN 'Creditos'
        WHEN c.payment_choice IS NULL THEN 'Desconhecido'
        ELSE c.payment_choice
      END,
      c.value,
      c.installments,
      COALESCE(c.installment_value, c.value),
      c.created_at,
      c.updated_at,
      c.confirmed_at,
      c.canceled_at,
      c.requested_refund_at,
      c.refunded_at
    FROM
      contributions c
    WHERE
      c.state <> 'deleted';
    UPDATE payment_notifications SET payment_id = contribution_id WHERE EXISTS (SELECT true FROM payments p WHERE p.id = payment_notifications.contribution_id);
    SELECT setval('payments_id_seq', (SELECT max(id) FROM payments));
    SQL
  end

  def down
    execute "TRUNCATE TABLE payments;"
  end
end
