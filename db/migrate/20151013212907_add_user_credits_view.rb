class AddUserCreditsView < ActiveRecord::Migration
  def change
    execute <<-SQL

    CREATE OR REPLACE VIEW "1".user_credits AS 
      SELECT u.id,
          u.id as user_id,
          case when u.zero_credits THEN 0 ELSE coalesce(ct.credits, 0) END as credits
      FROM users u
          LEFT JOIN (
      SELECT
          c.user_id,
          sum(
              CASE
          WHEN lower(pa.gateway) = 'pagarme'::text THEN 0::numeric
          WHEN p.state::text <> 'failed'::text AND NOT uses_credits(pa.*) THEN 0::numeric
          WHEN p.state::text = 'failed'::text AND uses_credits(pa.*) THEN 0::numeric
          WHEN p.state::text = 'failed'::text AND ((pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text])) AND NOT uses_credits(pa.*) OR uses_credits(pa.*) AND NOT (pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text]))) THEN 0::numeric
          WHEN p.state::text = 'failed'::text AND NOT uses_credits(pa.*) AND pa.state = 'paid'::text THEN pa.value
          ELSE pa.value * (-1)::numeric
              END
          ) - COALESCE((SELECT sum(amount)/100 FROM user_transfers ut WHERE ut.status = 'transferred' AND ut.user_id = c.user_id), 0::numeric)
            - COALESCE((SELECT sum(amount) FROM donations d WHERE d.user_id = c.user_id AND NOT EXISTS(SELECT 1 FROM contributions c WHERE c.donation_id = d.id)), 0::numeric) AS credits
              FROM 
          contributions c
          JOIN payments pa ON c.id = pa.contribution_id
          JOIN projects p ON c.project_id = p.id
          WHERE pa.state = ANY (confirmed_states())
          GROUP BY c.user_id
        ) ct ON u.id = ct.user_id;

      grant select on "1".user_credits to anonymous;
    SQL
  end
end
