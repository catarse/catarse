class ProjectAccountTriggers < ActiveRecord::Migration
    def up
      execute <<-SQL
CREATE UNIQUE INDEX unq_project_id_idx
    ON public.balance_transfers (project_id);

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
                RAISE EXCEPTION 'project account have unsolved error';
            END IF;

            RETURN NULL;
        END;
    $function$;

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
    $function$;

CREATE CONSTRAINT TRIGGER project_checks_before_transfer
    AFTER INSERT ON public.balance_transfers
    FOR EACH ROW WHEN (NEW.project_id IS NOT NULL)
    EXECUTE PROCEDURE public.project_checks_before_transfer();

CREATE TRIGGER approve_project_account
    INSTEAD OF INSERT ON "1".project_accounts
    FOR EACH ROW EXECUTE PROCEDURE public.approve_project_account();

GRANT INSERT ON "1".project_accounts TO web_user, admin;
GRANT SELECT ON "1".project_transfers TO web_user, admin;
GRANT SELECT ON "1".project_totals TO web_user, admin;
    SQL
    end

    def down
      execute <<-SQL
DROP INDEX unq_project_id_idx;
DROP FUNCTION approve_project_account() CASCADE;
DROP FUNCTION project_checks_before_transfer() CASCADE;
      SQL
    end
end
