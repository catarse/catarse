class DropUnsuedTriggerOnBalanceTransfers < ActiveRecord::Migration
    def up
    execute <<-SQL
set statement_timeout to 0;
DROP FUNCTION public.insert_balance_transfer();
    SQL
  end

  def down
    execute <<-SQL
set statement_timeout to 0;
CREATE OR REPLACE FUNCTION public.insert_balance_transfer()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        DECLARE
            v_balance "1".balances;
            v_balance_transfer_id integer;
            v_balance_transfer "1".balance_transfers;
        BEGIN
            IF NOT public.is_owner_or_admin(NEW.user_id) THEN
                RAISE EXCEPTION 'insufficient privileges to insert balance_transactions';
            END IF;

            SELECT * FROM "1".balances 
                WHERE user_id = NEW.user_id
                INTO v_balance;

            IF COALESCE(v_balance.amount, 0) <= 0 THEN
                RAISE EXCEPTION 'insufficient funds';
            END IF;

            INSERT INTO public.balance_transfers (user_id, amount, created_at)
                VALUES (NEW.user_id, v_balance.amount, now())
                RETURNING id INTO v_balance_transfer_id;

            INSERT INTO public.balance_transactions (user_id, event_name, balance_transfer_id, created_at, amount)
                VALUES (NEW.user_id, 'balance_transfer_request', v_balance_transfer_id, now(), (v_balance.amount * -1));

            SELECT * FROM "1".balance_transfers WHERE id = v_balance_transfer_id
                INTO v_balance_transfer;

            RETURN v_balance_transfer;
        END;
    $function$
;
    SQL
  end
end
