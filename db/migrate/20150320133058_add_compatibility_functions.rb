class AddCompatibilityFunctions < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION confirmed_states() RETURNS text[] AS $$
      SELECT '{"paid", "pending_refund", "refunded"}'::text[];
    $$ LANGUAGE SQL;

    CREATE OR REPLACE FUNCTION confirmed(contributions) RETURNS boolean AS $$
      SELECT EXISTS (
        SELECT true
        FROM 
          payments p 
          JOIN contributions_payments cp ON cp.payment_id = p.id
        WHERE cp.contribution_id = $1.id AND p.state = ANY(confirmed_states())
      );
    $$ LANGUAGE SQL;
    SQL
=begin
    remove_column :contributions, :confirmed_at
    remove_column :contributions, :key
    remove_column :contributions, :credits
    remove_column :contributions, :payment_method
    remove_column :contributions, :payment_token
    remove_column :contributions, :payment_id
    remove_column :contributions, :state
    remove_column :contributions, :waiting_confirmation_at
    remove_column :contributions, :canceled_at
    remove_column :contributions, :refunded_at
    remove_column :contributions, :requested_refund_at
    remove_column :contributions, :refunded_and_canceled_at
    remove_column :contributions, :invalid_payment_at
    remove_column :contributions, :slip_url
    remove_column :contributions, :installments
    remove_column :contributions, :address_country
    remove_column :contributions, :acquirer_name
    remove_column :contributions, :acquirer_tid
    remove_column :contributions, :installment_value
    remove_column :contributions, :card_brand
=end
  end

  def down
    execute <<-SQL
    DROP FUNCTION confirmed_states();
    SQL
  end
end
