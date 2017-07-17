class AddTitleToReports < ActiveRecord::Migration
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
    COALESCE(su.address ->> 'address_street'::text, u.address_street, b.address_street) AS street,
    COALESCE(su.address ->> 'address_complement'::text, u.address_complement, b.address_complement) AS complement,
    COALESCE(su.address ->> 'address_number'::text, u.address_number, b.address_number) AS address_number,
    COALESCE(su.address ->> 'address_neighbourhood'::text, u.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,
    COALESCE(su.address ->> 'address_city'::text, u.address_city, b.address_city) AS city,
    COALESCE(su.state_name::text, u.address_state, b.address_state) AS address_state,
    COALESCE(su.address ->> 'address_zip_code'::text, u.address_zip_code, b.address_zip_code) AS zip_code,
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
  WHERE pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text]);
    SQL
  end
end
