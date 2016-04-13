class AddedProjectAccountApproveNotificationDeliver < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION approve_project_account() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
            
            INSERT INTO public.project_notifications(project_id, user_id, locale, template_name, from_email, from_name, metadata) VALUES
                (v_project.id, v_project.user_id, 'pt', 'project_account_approve', settings('email_adm'), settings('company_name'), json_build_object(
                    'transfer_limit_date', to_char(v_project_acc.transfer_limit_date, 'DD/MM/YYYY'),
                    'transfer_amount', v_project_transfer.total_amount
                )::jsonb);

            RETURN v_project_acc;
        END;
    $$;

    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION approve_project_account() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
    $$;

    SQL
  end
end
