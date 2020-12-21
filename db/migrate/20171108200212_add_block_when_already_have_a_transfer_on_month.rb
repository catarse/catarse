class AddBlockWhenAlreadyHaveATransferOnMonth < ActiveRecord::Migration[4.2]
  def up
    execute %Q{
      grant delete on public.contribution_notifications to web_user, admin;
      grant delete on public.project_notifications to web_user, admin;
CREATE OR REPLACE FUNCTION public.withdraw_balance()
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
             IF v_balance.in_period_yet is not null AND v_balance.in_period_yet THEN
                RAISE EXCEPTION 'already requested transfer this month';
             END IF;
             INSERT INTO public.balance_transfers (user_id, amount, created_at)
                 VALUES (NEW.user_id, v_balance.amount, now())
                 RETURNING id INTO v_balance_transfer_id;
             INSERT INTO public.balance_transactions (user_id, event_name, balance_transfer_id, created_at, amount)
                 VALUES (NEW.user_id, 'balance_transfer_request', v_balance_transfer_id, now(), (v_balance.amount * -1));
             INSERT INTO public.notifications(user_id, template_name, metadata, created_at, updated_at) VALUES
                 (NEW.user_id, 'balance_transfer_request', json_build_object(
                     'from_email', settings('email_contact'),
                     'from_name', settings('company_name'),
                     'associations', json_build_object('balance_transfer_id', v_balance_transfer_id)
                 )::jsonb, now(), now());

             DELETE from contribution_notifications where template_name = 'contribution_refunded' and user_id = NEW.user_id and deliver_at > current_timestamp;
             DELETE from project_notifications where template_name = 'project_success' and user_id = NEW.user_id and deliver_at > current_timestamp;

             SELECT * FROM "1".balance_transfers WHERE id = v_balance_transfer_id
                 INTO v_balance_transfer;
             RETURN v_balance_transfer;
         END;
         $function$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.withdraw_balance()
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
             INSERT INTO public.notifications(user_id, template_name, metadata, created_at, updated_at) VALUES
                 (NEW.user_id, 'balance_transfer_request', json_build_object(
                     'from_email', settings('email_contact'),
                     'from_name', settings('company_name'),
                     'associations', json_build_object('balance_transfer_id', v_balance_transfer_id)
                 )::jsonb, now(), now());

             DELETE from contribution_notifications where template_name = 'contribution_refunded' and user_id = NEW.user_id and deliver_at > current_timestamp;
             DELETE from project_notifications where template_name = 'project_success' and user_id = NEW.user_id and deliver_at > current_timestamp;

             SELECT * FROM "1".balance_transfers WHERE id = v_balance_transfer_id
                 INTO v_balance_transfer;
             RETURN v_balance_transfer;
         END;
         $function$;

}
  end
end
