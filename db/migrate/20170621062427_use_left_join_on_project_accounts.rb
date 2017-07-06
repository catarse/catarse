class UseLeftJoinOnProjectAccounts < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "1"."project_accounts" AS 
 SELECT p.id,
    p.id AS project_id,
    p.user_id,
    u.email AS user_email,
    b.name AS bank_name,
    b.code AS bank_code,
    ba.agency,
    ba.agency_digit,
    ba.account,
    ba.account_digit,
    ba.account_type,
    u.name AS owner_name,
    u.cpf AS owner_document,
    (u.state_inscription)::text AS state_inscription,
    u.address_street,
    u.address_number,
    u.address_complement,
    u.address_neighbourhood,
    u.address_city,
    u.address_state,
    u.address_zip_code,
    u.phone_number,
    NULL::text AS error_reason,
    bt.state AS transfer_state,
    bt.transfer_limit_date,
    u.account_type AS user_type
   FROM ((((projects p
     JOIN users u ON ((u.id = p.user_id)))
     LEFT JOIN bank_accounts ba ON ((u.id = ba.user_id)))
     LEFT JOIN banks b ON ((b.id = ba.bank_id)))
     LEFT JOIN "1".balance_transfers bt ON ((bt.project_id = p.id)))
  WHERE is_owner_or_admin(p.user_id);
}
  end
end
