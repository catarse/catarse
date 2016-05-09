class RemovePcc < ActiveRecord::Migration
  def up
    execute %Q{
DROP VIEW "1".project_transfers;
CREATE VIEW "1".project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.paid_pledged AS pledged,
    public.zone_timestamp(p.expires_at) AS expires_at,
    public.zone_timestamp(COALESCE(public.successful_at(p.*), public.failed_at(p.*))) AS finished_at,
    pt.paid_total_payment_service_fee AS gateway_fee,
    public.total_catarse_fee(p.*) AS catarse_fee,
    public.total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - public.total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    public.irrf_tax(p.*) AS irrf_tax,
    (((pt.paid_pledged - public.total_catarse_fee(p.*)) + public.irrf_tax(p.*))) AS total_amount
   FROM (public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
  WHERE (public.is_owner_or_admin(p.user_id) OR ("current_user"() = 'catarse'::name));

DROP VIEW financial.project_transfers;
CREATE VIEW financial.project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.paid_pledged AS pledged,
    public.zone_timestamp(p.expires_at) AS expires_at,
    public.zone_timestamp(COALESCE(public.successful_at(p.*), public.failed_at(p.*))) AS finished_at,
    pt.paid_total_payment_service_fee AS gateway_fee,
    public.total_catarse_fee(p.*) AS catarse_fee,
    public.total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - public.total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    public.irrf_tax(p.*) AS irrf_tax,
    (((pt.paid_pledged - public.total_catarse_fee(p.*)) + public.irrf_tax(p.*))) AS total_amount
   FROM (public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)));

DROP MATERIALIZED VIEW financial.repasses;
CREATE MATERIALIZED VIEW financial.repasses AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.pledged,
    public.zone_timestamp(p.expires_at) AS expires_at,
    public.zone_timestamp(COALESCE(public.successful_at(p.*), public.failed_at(p.*))) AS finished_at,
    pt.total_payment_service_fee AS gateway_fee,
    public.total_catarse_fee(p.*) AS catarse_fee,
    public.total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - public.total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    public.irrf_tax(p.*) AS irrf_tax,
    (((pt.pledged - public.total_catarse_fee(p.*)) + public.irrf_tax(p.*))) AS total_amount
   FROM ((public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
  WHERE (COALESCE(fp.state, (p.state)::text) = 'successful'::text)
  ORDER BY p.expires_at DESC
  WITH NO DATA;


CREATE OR REPLACE FUNCTION public.approve_project_account() RETURNS trigger
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



GRANT select ON "1".project_transfers TO admin, web_user;

DROP FUNCTION public.pcc_tax(project projects);
    }
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION pcc_tax(project projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT
            CASE
            WHEN char_length(pa.owner_document) > 14 AND public.total_catarse_fee(p.*) >= 215.05 THEN
                0.0465 * public.total_catarse_fee_without_gateway_fee(p.*)
            ELSE 0 END
        FROM public.projects p
        LEFT JOIN public.project_accounts pa
            ON pa.project_id = p.id
        WHERE p.id = project.id;
    $$;

DROP VIEW "1".project_transfers;
CREATE VIEW "1".project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.paid_pledged AS pledged,
    public.zone_timestamp(p.expires_at) AS expires_at,
    public.zone_timestamp(COALESCE(public.successful_at(p.*), public.failed_at(p.*))) AS finished_at,
    pt.paid_total_payment_service_fee AS gateway_fee,
    public.total_catarse_fee(p.*) AS catarse_fee,
    public.total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - public.total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    public.irrf_tax(p.*) AS irrf_tax,
    public.pcc_tax(p.*) AS pcc_tax,
    (((pt.paid_pledged - public.total_catarse_fee(p.*)) + public.irrf_tax(p.*)) + public.pcc_tax(p.*)) AS total_amount
   FROM (public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
  WHERE (public.is_owner_or_admin(p.user_id) OR ("current_user"() = 'catarse'::name));

DROP VIEW financial.project_transfers;
CREATE VIEW financial.project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.paid_pledged AS pledged,
    public.zone_timestamp(p.expires_at) AS expires_at,
    public.zone_timestamp(COALESCE(public.successful_at(p.*), public.failed_at(p.*))) AS finished_at,
    pt.paid_total_payment_service_fee AS gateway_fee,
    public.total_catarse_fee(p.*) AS catarse_fee,
    public.total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - public.total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    public.irrf_tax(p.*) AS irrf_tax,
    public.pcc_tax(p.*) AS pcc_tax,
    (((pt.paid_pledged - public.total_catarse_fee(p.*)) + public.irrf_tax(p.*)) + public.pcc_tax(p.*)) AS total_amount
   FROM (public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)));

DROP MATERIALIZED VIEW financial.repasses;
CREATE MATERIALIZED VIEW financial.repasses AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.pledged,
    public.zone_timestamp(p.expires_at) AS expires_at,
    public.zone_timestamp(COALESCE(public.successful_at(p.*), public.failed_at(p.*))) AS finished_at,
    pt.total_payment_service_fee AS gateway_fee,
    public.total_catarse_fee(p.*) AS catarse_fee,
    public.total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - public.total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    public.irrf_tax(p.*) AS irrf_tax,
    public.pcc_tax(p.*) AS pcc_tax,
    (((pt.pledged - public.total_catarse_fee(p.*)) + public.irrf_tax(p.*)) + public.pcc_tax(p.*)) AS total_amount
   FROM ((public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
  WHERE (COALESCE(fp.state, (p.state)::text) = 'successful'::text)
  ORDER BY p.expires_at DESC
  WITH NO DATA;

CREATE OR REPLACE FUNCTION public.approve_project_account() RETURNS trigger
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

    }
  end
end
