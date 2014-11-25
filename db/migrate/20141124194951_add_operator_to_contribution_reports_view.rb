class AddOperatorToContributionReportsView < ActiveRecord::Migration
  def up
    drop_view :contribution_reports

    execute <<-SQL
    CREATE OR REPLACE VIEW contribution_reports AS
      SELECT b.project_id,
         u.name,
         replace(b.value::text, '.', ',') as value,
         replace(r.minimum_value::text, '.', ',') as minimum_value,
         r.description,
         b.payment_method,
         b.acquirer_name,
         b.acquirer_tid,
         b.payment_choice,
         replace(b.payment_service_fee::text, '.', ',') as payment_service_fee,
         b.key,
         (b.created_at)::date AS created_at,
         (b.confirmed_at)::date AS confirmed_at,
         u.email,
         b.payer_email,
         b.payer_name,
         COALESCE(b.payer_document, u.cpf) AS cpf,
         u.address_street,
         u.address_complement,
         u.address_number,
         u.address_neighbourhood,
         u.address_city,
         u.address_state,
         u.address_zip_code,
         b.state
        FROM ((contributions b
          JOIN users u ON ((u.id = b.user_id)))
          LEFT JOIN rewards r ON ((r.id = b.reward_id)))
       WHERE
       b.state in ('confirmed', 'refunded', 'requested_refund')
  SQL
  end
end
