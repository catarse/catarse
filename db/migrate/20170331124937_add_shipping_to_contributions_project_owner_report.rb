class AddShippingToContributionsProjectOwnerReport < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "public"."contribution_reports_for_project_owners" AS 
 SELECT b.project_id,
    COALESCE(r.id, 0) AS reward_id,
    p.user_id AS project_owner_id,
    r.description AS reward_description,
    (r.deliver_at)::date AS deliver_at,
    (pa.paid_at)::date AS confirmed_at,
    (b.created_at)::date AS created_at,
    pa.value AS contribution_value,
    (pa.value * ( SELECT (settings.value)::numeric AS value
           FROM settings
          WHERE (settings.name = 'catarse_fee'::text))) AS service_fee,
    u.email AS user_email,
    COALESCE(u.cpf, b.payer_document) AS cpf,
    u.name AS user_name,
    u.public_name,
    pa.gateway,
    b.anonymous,
    pa.state,
    waiting_payment(pa.*) AS waiting_payment,
    COALESCE(u.address_street, b.address_street) AS street,
    COALESCE(u.address_complement, b.address_complement) AS complement,
    COALESCE(u.address_number, b.address_number) AS address_number,
    COALESCE(u.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,
    COALESCE(u.address_city, b.address_city) AS city,
    COALESCE(u.address_state, b.address_state) AS address_state,
    COALESCE(u.address_zip_code, b.address_zip_code) AS zip_code,
    (CASE 
    WHEN sf.id is null THEN '' 
    ELSE sf.destination||' R$ '||sf.value END) as shipping_choice,
    COALESCE((case 
        when r.shipping_options = 'free' then 'Sem frete envolvido'
        when r.shipping_options = 'presential' then 'Retirada presencial'
        when r.shipping_options = 'international' then 'Frete Nacional e Internacional'
        when r.shipping_options = 'national' then 'Frete Nacional'
        end
    ), '') as shipping_option    
   FROM contributions b
     JOIN users u ON u.id = b.user_id
     JOIN projects p ON b.project_id = p.id
     JOIN payments pa ON pa.contribution_id = b.id
     LEFT JOIN rewards r ON r.id = b.reward_id
     LEFT JOIN shipping_fees sf ON sf.id = b.shipping_fee_id
  WHERE (pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text]));
}
  end
end
