class UpdateContributionsReport < ActiveRecord::Migration
  def change
    execute <<-SQL
    drop view contribution_reports_for_project_owners;
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
    case when su.address is not null then 
      su.address ->> 'address_street'::text
      else add.address_street
    end as street,
    case when su.address is not null then 
      su.address ->> 'address_complement'::text
      else add.address_complement
    end as complement,
    case when su.address is not null then 
      su.address ->> 'address_number'::text
      else add.address_number
    end as address_number,
    case when su.address is not null then 
      su.address ->> 'address_neighbourhood'::text
      else add.address_neighbourhood
    end as neighbourhood,
    case when su.address is not null then 
      su.address ->> 'address_city'::text
      else add.address_city
    end as city,
    case when su.address is not null then 
      su.state_name::text
      else add.address_state
    end as address_state,
    case when su.address is not null then 
      su.address ->> 'address_zip_code'::text
      else add.address_zip_code
    end as zip_code,
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
    r.title,
    case when su.address is not null then 
      'Entrega'::text
      else
      'Pagamento - Só use esse endereço se não conseguir confirmar o endereço de entrega! Para confirmar o endereço de entrega, envie um questionário. Saiba como aqui: http://catar.se/quest'::text
    end as address_type,
    u.id as user_id
   FROM contributions b
     JOIN users u ON u.id = b.user_id
     JOIN projects p ON b.project_id = p.id
     JOIN payments pa ON pa.contribution_id = b.id
     LEFT JOIN rewards r ON r.id = b.reward_id
     LEFT JOIN shipping_fees sf ON sf.id = b.shipping_fee_id
     LEFT JOIN "1".surveys su ON su.contribution_id = pa.contribution_id
     LEFT JOIN addresses add ON add.id = b.address_id
  WHERE pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text]);
    SQL

  end
end
