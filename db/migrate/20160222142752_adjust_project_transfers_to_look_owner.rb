class AdjustProjectTransfersToLookOwner < ActiveRecord::Migration
  def up
    execute <<-SQL
GRANT INSERT ON "1".project_accounts TO web_user, admin;
GRANT SELECT ON "1".project_transfers TO web_user, admin;
GRANT SELECT ON "1".project_totals TO web_user, admin;

CREATE OR REPLACE FUNCTION public.project_checks_before_transfer()
 RETURNS trigger
 LANGUAGE plpgsql
 STABLE
AS $function$
        BEGIN
            IF NOT EXISTS (
                SELECT true FROM "1".project_transitions pt
                WHERE pt.state = 'successful' AND pt.project_id = NEW.project_id
            ) THEN
                RAISE EXCEPTION 'project need to be successful';
            END IF;

            IF EXISTS (
                SELECT true FROM "1".project_accounts pa
                WHERE pa.error_reason IS NOT NULL AND pa.project_id = NEW.project_id
            ) THEN
                RAISE EXCEPTION 'project account has an error';
            END IF;

            RETURN NULL;
        END;
    $function$
;

CREATE OR REPLACE FUNCTION public.approve_project_account()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        DECLARE
            v_project public.projects;
            v_project_transfer "1".project_transfers;
            v_balance_transfer public.balance_transfers;
            v_project_acc "1".project_accounts;
        BEGIN
            SELECT * FROM projects
                WHERE id = NEW.project_id INTO v_project;

            SELECT * FROM "1".project_transfers
                WHERE project_id = v_project.id INTO v_project_transfer;

            IF NOT public.is_owner_or_admin(v_project.user_id) THEN
                RAISE EXCEPTION 'insufficient privileges to insert on project_accounts';
            END IF;

            -- create balance transfer
            INSERT INTO public.balance_transfers
                (user_id, project_id, amount, created_at) VALUES
                (v_project.user_id, v_project.id, v_project_transfer.total_amount, now())
                RETURNING * INTO v_balance_transfer;

            SELECT * FROM "1".project_accounts WHERE project_id = v_project.id
                INTO v_project_acc;

            -- create balance transactions
            INSERT INTO public.balance_transactions
                (project_id, user_id, balance_transfer_id, event_name, amount, created_at) VALUES
                (v_project.id, v_project.user_id, null, 'successful_project_pledged', v_project_transfer.pledged, now()),
                (v_project.id, v_project.user_id, null, 'catarse_project_service_fee', (v_project_transfer.catarse_fee * -1), now()),
                (v_project.id, v_project.user_id, v_balance_transfer.id, 'balance_transfer_project', (v_project_transfer.total_amount * -1), now());

            IF v_project_transfer.pcc_tax > 0 THEN
                INSERT INTO public.balance_transactions
                    (project_id, user_id, event_name, amount, created_at) VALUES
                    (v_project.id, v_project.user_id, 'pcc_tax_project', v_project_transfer.pcc_tax, now());
            END IF;

            IF v_project_transfer.irrf_tax > 0 THEN
                INSERT INTO public.balance_transactions
                    (project_id, user_id, event_name, amount, created_at) VALUES
                    (v_project.id, v_project.user_id, 'irrf_tax_project', v_project_transfer.irrf_tax, now());
            END IF;

            RETURN v_project_acc;
        END;
    $function$
;

CREATE OR REPLACE VIEW "1".project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.paid_pledged AS pledged,
    zone_timestamp(p.expires_at) AS expires_at,
    zone_timestamp(COALESCE(successful_at(p.*), failed_at(p.*))) AS finished_at,
    pt.paid_total_payment_service_fee AS gateway_fee,
    total_catarse_fee(p.*) AS catarse_fee,
    total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    irrf_tax(p.*) AS irrf_tax,
    pcc_tax(p.*) AS pcc_tax,
    (((pt.paid_pledged - total_catarse_fee(p.*)) + irrf_tax(p.*)) + pcc_tax(p.*)) AS total_amount
   FROM (public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
   WHERE public.is_owner_or_admin(p.user_id);
    SQL
  end
end
