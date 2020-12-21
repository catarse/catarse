class AddCancelationRequestToBalances < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
CREATE OR REPLACE VIEW "1"."balances" AS
 SELECT u.id AS user_id,
    balance.amount,
    last_transfer.amount AS last_transfer_amount,
    last_transfer.created_at AS last_transfer_created_at,
    last_transfer.in_period_yet,
    cancelation.has_cancelation_request
   FROM ((users u
     LEFT JOIN LATERAL ( SELECT sum(bt.amount) AS amount
           FROM balance_transactions bt
          WHERE (bt.user_id = u.id)) balance ON (true))
     LEFT JOIN LATERAL (
     select exists (
        select true from projects p where
        p.user_id = u.id
        and has_cancelation_request(p.*)
        ) as has_cancelation_request
     ) cancelation ON true
     LEFT JOIN LATERAL ( SELECT (bt.amount * ((-1))::numeric) AS amount,
            bt.created_at,
            (to_char(bt.created_at, 'MM/YYY'::text) = to_char(now(), 'MM/YYY'::text)) AS in_period_yet
           FROM balance_transactions bt
          WHERE (((bt.user_id = u.id) AND (bt.event_name = ANY (ARRAY['balance_transfer_request'::text, 'balance_transfer_project'::text]))) AND (NOT (EXISTS ( SELECT true AS bool
                   FROM balance_transactions bt2
                  WHERE (((bt2.user_id = u.id) AND (bt2.created_at > bt.created_at)) AND (bt2.event_name = 'balance_transfer_error'::text))))))
          ORDER BY bt.created_at DESC
         LIMIT 1) last_transfer ON (true))
  WHERE is_owner_or_admin(u.id);
    SQL
  end
end
