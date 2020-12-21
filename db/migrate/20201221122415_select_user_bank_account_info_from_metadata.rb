class SelectUserBankAccountInfoFromMetadata < ActiveRecord::Migration[6.1]

    def up
        execute <<-SQL

        CREATE OR REPLACE VIEW "1"."user_balance_transfers" AS 
        SELECT 
            bt.user_id,
            bt.amount,
            transfer_limit_date(bt.*) AS funding_estimated_date,
            current_state(bt.*) AS status,
            zone_timestamp(transferred_transition.created_at) AS transferred_at,
            zone_timestamp(transferred_transition.created_at)::date AS transferred_date,
            zone_timestamp(bt.created_at) AS requested_in,
            COALESCE(bank_account.owner_name, u.name) AS user_name,
            COALESCE(bank_account.bank_name, transferred_transition.bank_name) AS bank_name,
            COALESCE(bank_account.agency, transferred_transition.agency) AS agency,
            COALESCE(bank_account.agency_digit, transferred_transition.agency_digit) AS agency_digit,
            COALESCE(bank_account.account, transferred_transition.account) AS account,
            COALESCE(bank_account.account_digit, transferred_transition.account_digit) AS account_digit,
            COALESCE(bank_account.bank_account_type, transferred_transition.bank_account_type) AS account_type,
            COALESCE(bank_account.document_type, transferred_transition.document_type) AS document_type,
            COALESCE(bank_account.document_number, transferred_transition.document_number) AS document_number
        FROM balance_transfers bt
        LEFT JOIN LATERAL (
            SELECT 
                ba.user_id,
                bt.metadata->>'bank_name'::text AS bank_name,
                bt.metadata->>'bank_code'::text AS bank_code,
                bt.metadata->>'account'::text AS account,
                bt.metadata->>'account_digit'::text AS account_digit,
                bt.metadata->>'agency'::text AS agency,
                bt.metadata->>'agency_digit'::text AS agency_digit,
                bt.metadata->>'name'::text AS owner_name,
                bt.metadata->>'document_number'::text AS document_number,
                ba.created_at,
                ba.updated_at,
                ba.id AS bank_account_id,
                ba.bank_id,
                bt.metadata->>'bank_account_type'::text AS bank_account_type,
                bt.metadata->>'document_type'::text AS document_type
            FROM bank_accounts ba
            JOIN users u_1 ON u_1.id = ba.user_id
            JOIN banks b ON b.id = ba.bank_id
            WHERE ba.user_id = bt.user_id
            LIMIT 1
        ) bank_account ON bank_account.user_id = bt.user_id
        JOIN users u ON u.id = bt.user_id
        LEFT JOIN balance_transfer_transitions btt ON btt.balance_transfer_id = bt.id AND btt.most_recent
        LEFT JOIN LATERAL (
            SELECT
                btt1.id,
                btt1.to_state,
                btt1.metadata,
                btt1.balance_transfer_id,
                btt1.most_recent,
                btt1.metadata->'transfer_data'->'bank_account'->>'agencia'::text AS agency,
                btt1.metadata->'transfer_data'->'bank_account'->>'agencia_dv'::text AS agency_digit,
                btt1.metadata->'transfer_data'->'bank_account'->>'conta'::text AS account,
                btt1.metadata->'transfer_data'->'bank_account'->>'conta_dv'::text AS account_digit,
                btt1.metadata->'transfer_data'->'bank_account'->>'type'::text AS bank_account_type,
                btt1.metadata->'transfer_data'->'bank_account'->>'document_type'::text AS document_type,
                regexp_replace(btt1.metadata->'transfer_data'->'bank_account'->>'document_number'::text, '[^0-9]+', '', 'g') AS document_number,
                bank_account_1.bank_name,
                to_timestamp(btt1.metadata->'transfer_data'->> 'date_created'::text, 'YYYY-MM-DD HH24:MI:SS'::text)::timestamp without time zone AS created_at
            FROM balance_transfer_transitions btt1
            LEFT JOIN LATERAL (
                SELECT
                    ba.user_id,
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
                FROM bank_accounts ba
                JOIN users u_1 ON u_1.id = bt.user_id
                JOIN banks b ON b.id = ba.bank_id
                WHERE ba.user_id = bt.user_id
                LIMIT 1
            ) bank_account_1 ON true
            WHERE btt1.balance_transfer_id = bt.id AND btt1.to_state::text <> 'authorized'::text
            ORDER BY btt1.id DESC
            LIMIT 1
        ) transferred_transition ON true
        WHERE is_owner_or_admin(bt.user_id);

        SQL
    end

    def down
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
                    WHEN (transferred_transition.bank_name IS NULL) THEN bank_account.bank_name
                    ELSE transferred_transition.bank_name
                END AS bank_name,
                CASE
                    WHEN (transferred_transition.agency IS NULL) THEN bank_account.agency
                    ELSE transferred_transition.agency
                END AS agency,
                CASE
                    WHEN (transferred_transition.agency_digit IS NULL) THEN bank_account.agency_digit
                    ELSE transferred_transition.agency_digit
                END AS agency_digit,
                CASE
                    WHEN (transferred_transition.account IS NULL) THEN bank_account.account
                    ELSE transferred_transition.account
                END AS account,
                CASE
                    WHEN (transferred_transition.account_digit IS NULL) THEN bank_account.account_digit
                    ELSE transferred_transition.account_digit
                END AS account_digit,
                CASE
                    WHEN (transferred_transition.bank_account_type IS NULL) THEN bank_account.bank_account_type
                    ELSE transferred_transition.bank_account_type
                END AS account_type,
                CASE
                    WHEN (transferred_transition.document_type IS NULL) THEN bank_account.document_type
                    ELSE transferred_transition.document_type
                END AS document_type,
                CASE
                    WHEN (transferred_transition.document_number IS NULL) THEN regexp_replace(bank_account.document_number, '[^0-9]+'::text, ''::text, 'g'::text)
                    ELSE regexp_replace(transferred_transition.document_number, '[^0-9]+'::text, ''::text, 'g'::text)
                END AS document_number
        FROM ((((balance_transfers bt
            LEFT JOIN LATERAL ( SELECT ba.user_id,
                    bt.metadata->>'bank_name' AS bank_name,
                    bt.metadata->>'bank_code' AS bank_code,
                    bt.metadata->>'account' AS account,
                    bt.metadata->>'account_digit' AS account_digit,
                    bt.metadata->>'agency' AS agency,
                    bt.metadata->>'agency_digit' AS agency_digit,
                    bt.metadata->>'name' AS owner_name,
                    bt.metadata->>'document_number' AS document_number,
                    ba.created_at,
                    ba.updated_at,
                    ba.id AS bank_account_id,
                    ba.bank_id,
                    bt.metadata->>'bank_account_type' AS bank_account_type,
                    bt.metadata->>'document_type' AS document_type
                FROM ((bank_accounts ba
                    JOIN users u_1 ON ((u_1.id = ba.user_id)))
                    JOIN banks b ON ((b.id = ba.bank_id)))
                WHERE (ba.user_id = bt.user_id)
                LIMIT 1) bank_account ON ((bank_account.user_id = bt.user_id)))
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
                    bank_account_1.bank_name,
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
                        LIMIT 1) bank_account_1 ON (true))
                WHERE ((btt1.balance_transfer_id = bt.id) AND ((btt1.to_state)::text <> 'authorized'::text))
                ORDER BY btt1.id DESC
                LIMIT 1) transferred_transition ON (true))
        WHERE is_owner_or_admin(bt.user_id);

        grant select on "1".user_balance_transfers to admin, web_user;
        grant select on public.balance_transfers to admin, web_user;
        grant select on public.bank_accounts to admin, web_user;
    
        SQL
    end
end
