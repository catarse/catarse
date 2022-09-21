class UpdateContributionReportsForProjectOwners < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
    DROP VIEW public.contribution_reports_for_project_owners;
    CREATE OR REPLACE VIEW "public"."contribution_reports_for_project_owners" AS
     SELECT b.project_id,
        COALESCE(r.id, 0) AS reward_id,
        p.user_id AS project_owner_id,
        r.description AS reward_description,
        (r.deliver_at)::date AS deliver_at,
        (pa.paid_at) AS confirmed_at,
        (b.created_at) AS created_at,
        numbertocurrency(pa.value) AS contribution_value,
        numbertocurrency((((pa.value * p.service_fee) - pa.gateway_fee) - COALESCE(aa.cost, (0)::numeric))) AS service_fee,
        numbertocurrency(pa.gateway_fee) AS payment_method_fee,
        numbertocurrency(COALESCE(aa.cost, (0)::numeric)) AS antifraud_cost,
        numbertocurrency((pa.value * ((1)::numeric - p.service_fee))) AS contribution_value_net,
        u.email AS user_email,
        COALESCE(u.cpf, b.payer_document) AS cpf,
        u.name AS user_name,
        u.public_name,
        pa.payment_method AS gateway,
        b.anonymous,
        pa.state,
        waiting_payment(pa.*) AS waiting_payment,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.address ->> 'phone_number'::text)
                ELSE add.phone_number
            END AS phone_number,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_street'::text)
                ELSE add.address_street
            END AS street,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_complement'::text)
                ELSE add.address_complement
            END AS complement,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_number'::text)
                ELSE add.address_number
            END AS address_number,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_neighbourhood'::text)
                ELSE add.address_neighbourhood
            END AS neighbourhood,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_city'::text)
                ELSE add.address_city
            END AS city,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.state_name)::text
                WHEN (COALESCE(add.address_state, ''::text) <> ''::text) THEN add.address_state
                ELSE (st.acronym)::text
            END AS address_state,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_zip_code'::text)
                ELSE add.address_zip_code
            END AS zip_code,
            CASE
                WHEN (sf.id IS NULL) THEN ''::text
                ELSE (st.acronym)::text
            END AS shipping_choice,
            CASE
                WHEN (sf.id IS NULL) THEN ''::text
                ELSE (' R$ '::text || numbertocurrency(sf.value))
            END AS shipping_amount,
        COALESCE(
            CASE
                WHEN (r.shipping_options = 'free'::text) THEN 'Sem frete envolvido'::text
                WHEN (r.shipping_options = 'presential'::text) THEN 'Retirada presencial'::text
                WHEN (r.shipping_options = 'international'::text) THEN 'Frete Nacional e Internacional'::text
                WHEN (r.shipping_options = 'national'::text) THEN 'Frete Nacional'::text
                ELSE NULL::text
            END, ''::text) AS shipping_option,
        su.open_questions,
        su.multiple_choice_questions,
        r.title,
            CASE
                WHEN (su.address IS NOT NULL) THEN 'Entrega'::text
                ELSE 'Pagamento - Só use esse endereço se não conseguir confirmar o endereço de entrega! Para confirmar o endereço de entrega, envie um questionário. Saiba como aqui: http://catar.se/quest'::text
            END AS address_type,
        u.id AS user_id,
        pa.gateway_id AS contribution_id,
            CASE
                WHEN (su.address IS NOT NULL) THEN (su.country_name)::text
                ELSE country.name
            END AS address_country
       FROM ((((((((((contributions b
         JOIN users u ON ((u.id = b.user_id)))
         JOIN projects p ON ((b.project_id = p.id)))
         JOIN payments pa ON ((pa.contribution_id = b.id)))
         LEFT JOIN rewards r ON ((r.id = b.reward_id)))
         LEFT JOIN shipping_fees sf ON ((sf.id = b.shipping_fee_id)))
         LEFT JOIN "1".surveys su ON ((su.contribution_id = pa.contribution_id)))
         LEFT JOIN addresses add ON ((add.id = b.address_id)))
         LEFT JOIN states st ON ((st.id = add.state_id)))
         LEFT JOIN countries country ON ((country.id = add.country_id)))
         LEFT JOIN antifraud_analyses aa ON ((aa.payment_id = pa.id)))
      WHERE (pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text, 'chargeback'::text]));
    SQL
  end

  def down
    execute <<-SQL
    DROP VIEW public.contribution_reports_for_project_owners;
    CREATE OR REPLACE VIEW "public"."contribution_reports_for_project_owners" AS
    SELECT b.project_id,
       COALESCE(r.id, 0) AS reward_id,
       p.user_id AS project_owner_id,
       r.description AS reward_description,
       (r.deliver_at)::date AS deliver_at,
       (pa.paid_at)::date AS confirmed_at,
       (b.created_at)::date AS created_at,
       numbertocurrency(pa.value) AS contribution_value,
       numbertocurrency((((pa.value * p.service_fee) - pa.gateway_fee) - COALESCE(aa.cost, (0)::numeric))) AS service_fee,
       numbertocurrency(pa.gateway_fee) AS payment_method_fee,
       numbertocurrency(COALESCE(aa.cost, (0)::numeric)) AS antifraud_cost,
       numbertocurrency((pa.value * ((1)::numeric - p.service_fee))) AS contribution_value_net,
       u.email AS user_email,
       COALESCE(u.cpf, b.payer_document) AS cpf,
       u.name AS user_name,
       u.public_name,
       pa.payment_method AS gateway,
       b.anonymous,
       pa.state,
       waiting_payment(pa.*) AS waiting_payment,
           CASE
               WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_street'::text)
               ELSE add.address_street
           END AS street,
           CASE
               WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_complement'::text)
               ELSE add.address_complement
           END AS complement,
           CASE
               WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_number'::text)
               ELSE add.address_number
           END AS address_number,
           CASE
               WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_neighbourhood'::text)
               ELSE add.address_neighbourhood
           END AS neighbourhood,
           CASE
               WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_city'::text)
               ELSE add.address_city
           END AS city,
           CASE
               WHEN (su.address IS NOT NULL) THEN (su.state_name)::text
               WHEN (COALESCE(add.address_state, ''::text) <> ''::text) THEN add.address_state
               ELSE (st.acronym)::text
           END AS address_state,
           CASE
               WHEN (su.address IS NOT NULL) THEN (su.address ->> 'address_zip_code'::text)
               ELSE add.address_zip_code
           END AS zip_code,
           CASE
               WHEN (sf.id IS NULL) THEN ''::text
               ELSE (st.acronym)::text
           END AS shipping_choice,
           CASE
               WHEN (sf.id IS NULL) THEN ''::text
               ELSE (' R$ '::text || numbertocurrency(sf.value))
           END AS shipping_amount,
       COALESCE(
           CASE
               WHEN (r.shipping_options = 'free'::text) THEN 'Sem frete envolvido'::text
               WHEN (r.shipping_options = 'presential'::text) THEN 'Retirada presencial'::text
               WHEN (r.shipping_options = 'international'::text) THEN 'Frete Nacional e Internacional'::text
               WHEN (r.shipping_options = 'national'::text) THEN 'Frete Nacional'::text
               ELSE NULL::text
           END, ''::text) AS shipping_option,
       su.open_questions,
       su.multiple_choice_questions,
       r.title,
           CASE
               WHEN (su.address IS NOT NULL) THEN 'Entrega'::text
               ELSE 'Pagamento - Só use esse endereço se não conseguir confirmar o endereço de entrega! Para confirmar o endereço de entrega, envie um questionário. Saiba como aqui: http://catar.se/quest'::text
           END AS address_type,
       u.id AS user_id,
       pa.gateway_id AS contribution_id,
           CASE
               WHEN (su.address IS NOT NULL) THEN (su.country_name)::text
               ELSE country.name
           END AS address_country
      FROM ((((((((((contributions b
        JOIN users u ON ((u.id = b.user_id)))
        JOIN projects p ON ((b.project_id = p.id)))
        JOIN payments pa ON ((pa.contribution_id = b.id)))
        LEFT JOIN rewards r ON ((r.id = b.reward_id)))
        LEFT JOIN shipping_fees sf ON ((sf.id = b.shipping_fee_id)))
        LEFT JOIN "1".surveys su ON ((su.contribution_id = pa.contribution_id)))
        LEFT JOIN addresses add ON ((add.id = b.address_id)))
        LEFT JOIN states st ON ((st.id = add.state_id)))
        LEFT JOIN countries country ON ((country.id = add.country_id)))
        LEFT JOIN antifraud_analyses aa ON ((aa.payment_id = pa.id)))
     WHERE (pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text, 'chargeback'::text]));
    SQL
  end
end
