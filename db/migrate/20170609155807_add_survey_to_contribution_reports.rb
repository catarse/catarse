class AddSurveyToContributionReports < ActiveRecord::Migration
  def change
    execute %Q{
    create or replace view "1".surveys as
SELECT s.id AS survey_id,
    c.project_id,
    c.id AS contribution_id,
    s.reward_id,
    s.confirm_address,
    s.sent_at,
    s.finished_at,
    ( SELECT json_agg(open_questions.*) AS json_agg
           FROM ( SELECT soq.id,
                    soq.question,
                    soq.description,
                    sa.answer,
                    sa.created_at AS answered_at
                   FROM survey_open_questions soq
                     LEFT JOIN survey_open_question_answers sa ON (sa.survey_open_question_id = soq.id and sa.contribution_id = c.id)
                  WHERE soq.survey_id = s.id) open_questions) AS open_questions,
    ( SELECT json_agg(m_questions.*) AS json_agg
           FROM ( SELECT smcq.id,
                    smcq.question,
                    sa.survey_question_choice_id,
                    sa.created_at AS answered_at,
                    ( SELECT json_agg(question_choices.*) AS choice_json_agg
                           FROM ( SELECT sqc.id,
                                    sqc.option
                                   FROM survey_question_choices sqc
                                  WHERE sqc.survey_multiple_choice_question_id = smcq.id) question_choices) AS question_choices,
                    smcq.description
                   FROM survey_multiple_choice_questions smcq
                     LEFT JOIN survey_multiple_choice_question_answers sa ON (sa.survey_multiple_choice_question_id = smcq.id and sa.contribution_id = c.id)
                  WHERE smcq.survey_id = s.id) m_questions) AS multiple_choice_questions,
    row_to_json(add.*) AS address,
    co.name_en AS country_name,
    st.acronym AS state_name
   FROM contributions c
     RIGHT JOIN surveys s ON s.reward_id = c.reward_id
     LEFT JOIN survey_address_answers saa ON saa.contribution_id = c.id
     LEFT JOIN addresses add ON add.id = saa.address_id
     LEFT JOIN countries co ON co.id = add.country_id
     LEFT JOIN states st ON st.id = add.state_id;



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
    COALESCE((su.address->>'address_street')::text, u.address_street, b.address_street) AS street,
    COALESCE((su.address->>'address_complement')::text, u.address_complement, b.address_complement) AS complement,
    COALESCE((su.address->>'address_number')::text, u.address_number, b.address_number) AS address_number,
    COALESCE((su.address->>'address_neighbourhood')::text, u.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,
    COALESCE((su.address->>'address_city')::text, u.address_city, b.address_city) AS city,
    COALESCE((su.state_name)::text, u.address_state, b.address_state) AS address_state,
    COALESCE((su.address->>'address_zip_code')::text, u.address_zip_code, b.address_zip_code) AS zip_code,
    (CASE 
    WHEN sf.id is null THEN '' 
    ELSE sf.destination||' R$ '||sf.value END) as shipping_choice,
    COALESCE((case 
        when r.shipping_options = 'free' then 'Sem frete envolvido'
        when r.shipping_options = 'presential' then 'Retirada presencial'
        when r.shipping_options = 'international' then 'Frete Nacional e Internacional'
        when r.shipping_options = 'national' then 'Frete Nacional'
        end
    ), '') as shipping_option,
    su.open_questions,
    su.multiple_choice_questions
   FROM contributions b
     JOIN users u ON u.id = b.user_id
     JOIN projects p ON b.project_id = p.id
     JOIN payments pa ON pa.contribution_id = b.id
     LEFT JOIN rewards r ON r.id = b.reward_id
     LEFT JOIN shipping_fees sf ON sf.id = b.shipping_fee_id
     LEFT JOIN "1".surveys su on su.contribution_id = pa.contribution_id
  WHERE (pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text]));
}
  end
end
