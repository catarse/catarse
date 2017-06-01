class AddWithdrawOperationToApi < ActiveRecord::Migration
  def change
    execute %Q{
create or replace function withdraw_balance() returns trigger as $$
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
$$ language plpgsql;


create trigger withdraw_balance instead of insert on "1".balance_transfers
    for each row execute procedure withdraw_balance();


GRANT SELECT, INSERT ON public.balance_transfers TO admin, web_user;
GRANT SELECT, INSERT ON "1".balance_transfers TO admin, web_user;
GRANT USAGE ON SEQUENCE balance_transfers_id_seq TO admin, web_user;
GRANT SELECT, INSERT ON public.balance_transactions TO admin, web_user;
GRANT USAGE ON SEQUENCE balance_transactions_id_seq TO admin, web_user;

drop trigger approve_project_account on "1".project_accounts;
}
  end
end
