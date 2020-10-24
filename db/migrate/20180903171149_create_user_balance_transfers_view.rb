class CreateUserBalanceTransfersView < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
    CREATE OR REPLACE VIEW "1"."user_balance_transfers" AS

    SELECT bt.user_id,
    bt.amount,
    transfer_limit_date(bt.*) AS funding_estimated_date,
    current_state(bt.*) AS status,
    zone_timestamp(transferred_transition.created_at) AS transferred_at,
    (zone_timestamp(transferred_transition.created_at))::date AS transferred_date,
    zone_timestamp(bt.created_at) AS requested_in,
    u.name AS user_name,
    CASE
        when transferred_transition.bank_name is null then bank_account.bank_name
        else transferred_transition.bank_name
    END as bank_name,
    CASE
        when transferred_transition.agency is null then bank_account.agency
        else transferred_transition.agency
    END as agency,
    CASE
        when transferred_transition.agency_digit is null then bank_account.agency_digit
        else transferred_transition.agency_digit
    END as agency_digit,
    CASE
        when transferred_transition.account is null then bank_account.account
        else transferred_transition.account
    END as account,
    CASE
        when transferred_transition.account_digit is null then bank_account.account_digit
        else transferred_transition.account_digit
    END as account_digit,
    CASE
        when transferred_transition.bank_account_type is null then bank_account.bank_account_type
        else transferred_transition.bank_account_type
    END as account_type,
    CASE
        when transferred_transition.document_type is null
            then (
                    CASE
                        when bank_account.document_type = 'pf' then 'cpf'::text
                        else 'cnpj'::text
                    END )
            else transferred_transition.document_type
    END as document_type,
    CASE
        when transferred_transition.document_number is null then regexp_replace(bank_account.document_number, '[^0-9]+'::text, ''::text, 'g'::text)
        else regexp_replace(transferred_transition.document_number, '[^0-9]+'::text, ''::text, 'g'::text)
    END as document_number

   FROM ((((balance_transfers bt
        LEFT JOIN LATERAL ( SELECT ba.user_id,
                    b.name AS bank_name,
                    b.code AS bank_code,
                    ba.account,
                    ba.account_digit,
                    ba.agency,
                    ba.agency_digit,
                    u_1.name AS owner_name,
                    u_1.cpf AS document_number,
                    ba.created_at,
                    ba.updated_at,
                    ba.id AS bank_account_id,
                    ba.bank_id,
                    ba.account_type AS bank_account_type,
                    u_1.account_type AS document_type
                   FROM bank_accounts ba
                     JOIN users u_1 ON u_1.id = ba.user_id
                     JOIN banks b ON b.id = ba.bank_id
                  WHERE ba.user_id = bt.user_id
                 LIMIT 1) as bank_account
                 on bank_account.user_id = bt.user_id
    )
     JOIN users u ON ((u.id = bt.user_id)))
     LEFT JOIN balance_transfer_transitions btt ON (((btt.balance_transfer_id = bt.id) AND btt.most_recent)))
     LEFT JOIN LATERAL ( SELECT btt1.id,
            btt1.to_state,
            btt1.metadata,
            btt1.balance_transfer_id,
            btt1.most_recent,
            (((btt1.metadata -> 'transfer_data'::text) -> 'bank_account'::text) ->> 'agencia'::text) AS agency,
            (((btt1.metadata -> 'transfer_data'::text) -> 'bank_account'::text) ->> 'agencia_dv'::text) AS agency_digit,
            (((btt1.metadata -> 'transfer_data'::text) -> 'bank_account'::text) ->> 'conta'::text) AS account,
            (((btt1.metadata -> 'transfer_data'::text) -> 'bank_account'::text) ->> 'conta_dv'::text) AS account_digit,
            (((btt1.metadata -> 'transfer_data'::text) -> 'bank_account'::text) ->> 'type'::text) AS bank_account_type,
            (((btt1.metadata -> 'transfer_data'::text) -> 'bank_account'::text) ->> 'document_type'::text) AS document_type,
            (((btt1.metadata -> 'transfer_data'::text) -> 'bank_account'::text) ->> 'document_number'::text) AS document_number,
            bank_account.bank_name,
            (to_timestamp(((btt1.metadata -> 'transfer_data'::text) ->> 'date_created'::text), 'YYYY-MM-DD HH24:MI:SS'::text))::timestamp without time zone AS created_at
           FROM (balance_transfer_transitions btt1
             LEFT JOIN LATERAL ( SELECT ba.user_id,
                    b.name AS bank_name,
                    b.code AS bank_code,
                    ba.account,
                    ba.account_digit,
                    ba.agency,
                    ba.agency_digit,
                    u_1.name AS owner_name,
                    u_1.cpf AS owner_document,
                    ba.created_at,
                    ba.updated_at,
                    ba.id AS bank_account_id,
                    ba.bank_id,
                    ba.account_type AS bank_account_type,
                    u_1.account_type
                   FROM ((bank_accounts ba
                     JOIN users u_1 ON ((u_1.id = bt.user_id)))
                     JOIN banks b ON ((b.id = ba.bank_id)))
                  WHERE (ba.user_id = bt.user_id)
                 LIMIT 1) bank_account ON (true))
          WHERE ((btt1.balance_transfer_id = bt.id) AND ((btt1.to_state)::text <> 'authorized'::text))
          ORDER BY btt1.id DESC
         LIMIT 1) transferred_transition ON (true))

      WHERE is_owner_or_admin(bt.user_id);

      grant select on "1"."user_balance_transfers" to web_user, admin;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW "1"."user_balance_transfers";
    SQL
  end
end
