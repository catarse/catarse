class FixAddressReferences < ActiveRecord::Migration
  def change
    execute <<-SQL
    create or replace view contribution_reports_for_project_owners as
SELECT b.project_id,
    COALESCE(r.id, 0) AS reward_id,
    p.user_id AS project_owner_id,
    r.description AS reward_description,
    r.deliver_at::date AS deliver_at,
    pa.paid_at::date AS confirmed_at,
    b.created_at::date AS created_at,
    pa.value AS contribution_value,
    pa.value * (( SELECT settings.value::numeric AS value
           FROM settings
          WHERE settings.name = 'catarse_fee'::text)) AS service_fee,
    u.email AS user_email,
    COALESCE(u.cpf, b.payer_document) AS cpf,
    u.name AS user_name,
    u.public_name,
    pa.gateway,
    b.anonymous,
    pa.state,
    waiting_payment(pa.*) AS waiting_payment,
    COALESCE(su.address ->> 'address_street'::text, add.address_street, add2.address_street) AS street,
    COALESCE(su.address ->> 'address_complement'::text, add.address_complement, add2.address_complement) AS complement,
    COALESCE(su.address ->> 'address_number'::text, add.address_number, add2.address_number) AS address_number,
    COALESCE(su.address ->> 'address_neighbourhood'::text, add.address_neighbourhood, add2.address_neighbourhood) AS neighbourhood,
    COALESCE(su.address ->> 'address_city'::text, add.address_city, add2.address_city) AS city,
    COALESCE(su.state_name::text, add.address_state, add2.address_state) AS address_state,
    COALESCE(su.address ->> 'address_zip_code'::text, add.address_zip_code, add2.address_zip_code) AS zip_code,
        CASE
            WHEN sf.id IS NULL THEN ''::text
            ELSE (sf.destination || ' R$ '::text) || sf.value
        END AS shipping_choice,
    COALESCE(
        CASE
            WHEN r.shipping_options = 'free'::text THEN 'Sem frete envolvido'::text
            WHEN r.shipping_options = 'presential'::text THEN 'Retirada presencial'::text
            WHEN r.shipping_options = 'international'::text THEN 'Frete Nacional e Internacional'::text
            WHEN r.shipping_options = 'national'::text THEN 'Frete Nacional'::text
            ELSE NULL::text
        END, ''::text) AS shipping_option,
    su.open_questions,
    su.multiple_choice_questions,
    r.title
   FROM contributions b
     JOIN users u ON u.id = b.user_id
     JOIN projects p ON b.project_id = p.id
     JOIN payments pa ON pa.contribution_id = b.id
     LEFT JOIN rewards r ON r.id = b.reward_id
     LEFT JOIN shipping_fees sf ON sf.id = b.shipping_fee_id
     LEFT JOIN "1".surveys su ON su.contribution_id = pa.contribution_id
     LEFT JOIN addresses add ON add.id = b.address_id
     LEFT JOIN addresses add2 ON add2.id = u.address_id
  WHERE pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text]);


    create or replace view "1".contribution_reports_for_project_owners as
SELECT b.project_id,
    COALESCE(r.id, 0) AS reward_id,
    p.user_id AS project_owner_id,
    r.description AS reward_description,
    r.deliver_at::date AS deliver_at,
    pa.paid_at::date AS confirmed_at,
    pa.value AS contribution_value,
    pa.value * (( SELECT settings.value::numeric AS value
           FROM settings
          WHERE settings.name = 'catarse_fee'::text)) AS service_fee,
    u.email AS user_email,
    COALESCE(u.cpf, b.payer_document) AS cpf,
    u.name AS user_name,
    pa.gateway,
    b.anonymous,
    pa.state,
    waiting_payment(pa.*) AS waiting_payment,
    COALESCE(add.address_street, add2.address_street) AS street,
    COALESCE(add.address_complement, add2.address_complement) AS complement,
    COALESCE(add.address_number, add2.address_number) AS address_number,
    COALESCE(add.address_neighbourhood, add2.address_neighbourhood) AS neighbourhood,
    COALESCE(add.address_city, add2.address_city) AS city,
    COALESCE(add.address_state, add2.address_state) AS address_state,
    COALESCE(add.address_zip_code, add2.address_zip_code) AS zip_code
   FROM contributions b
     JOIN users u ON u.id = b.user_id
     JOIN projects p ON b.project_id = p.id
     JOIN payments pa ON pa.contribution_id = b.id
     LEFT JOIN rewards r ON r.id = b.reward_id
     LEFT JOIN addresses add ON add.id = u.address_id
     LEFT JOIN addresses add2 ON add2.id = b.address_id
  WHERE pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text]);
    SQL
  end
end
