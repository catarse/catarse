class AddAnsweredAtToSurveysEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
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
                     LEFT JOIN survey_open_question_answers sa ON sa.survey_open_question_id = soq.id AND sa.contribution_id = c.id
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
                     LEFT JOIN survey_multiple_choice_question_answers sa ON sa.survey_multiple_choice_question_id = smcq.id AND sa.contribution_id = c.id
                  WHERE smcq.survey_id = s.id) m_questions) AS multiple_choice_questions,
    row_to_json(add.*) AS address,
    co.name_en AS country_name,
    st.acronym AS state_name,
    c.survey_answered_at as survey_answered_at
   FROM contributions c
     RIGHT JOIN surveys s ON s.reward_id = c.reward_id
     LEFT JOIN survey_address_answers saa ON saa.contribution_id = c.id
     LEFT JOIN addresses add ON add.id = saa.address_id
     LEFT JOIN countries co ON co.id = add.country_id
     LEFT JOIN states st ON st.id = add.state_id;

  grant SELECT on "1".surveys to web_user, admin;


     create or replace view "1".user_contributions as
SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.user_id,
    c.project_id,
    c.reward_id,
    p.permalink,
    p.name AS project_name,
    thumbnail_image(p.*) AS project_img,
    zone_timestamp(online_at(p.*)) AS project_online_date,
    zone_timestamp(p.expires_at) AS project_expires_at,
    p.state AS project_state,
    u.name AS user_name,
    thumbnail_image(u.*) AS user_profile_img,
    u.email,
    c.anonymous,
    c.payer_email,
    pa.key,
    pa.value,
    pa.installments,
    pa.installment_value,
    pa.state,
    is_second_slip(pa.*) AS is_second_slip,
    pa.gateway,
    pa.gateway_id,
    pa.gateway_fee,
    pa.gateway_data,
    pa.payment_method,
    zone_timestamp(pa.created_at) AS created_at,
    zone_timestamp(pa.created_at) AS pending_at,
    zone_timestamp(pa.paid_at) AS paid_at,
    zone_timestamp(pa.refused_at) AS refused_at,
    zone_timestamp(pa.pending_refund_at) AS pending_refund_at,
    zone_timestamp(pa.refunded_at) AS refunded_at,
    zone_timestamp(pa.deleted_at) AS deleted_at,
    zone_timestamp(pa.chargeback_at) AS chargeback_at,
    pa.full_text_index,
    waiting_payment(pa.*) AS waiting_payment,
    (EXISTS ( SELECT true AS bool
           FROM unsubscribes un
          WHERE un.project_id = c.project_id AND un.user_id = u.id)) AS unsubscribed,
    r.description AS reward_description,
    r.deliver_at,
    thumbnail_image(p.*, ''::text) AS project_image,
    sold_out(r.*) AS reward_sold_out,
    u.public_name,
    c.delivery_status,
    c.reward_sent_at,
    r.title AS reward_title,
    p.user_id AS project_user_id,
    ( SELECT COALESCE(u_1.public_name, u_1.name) AS "coalesce"
           FROM users u_1
          WHERE u_1.id = p.user_id) AS project_owner_name,
    row_to_json(su.*) AS survey,
    c.survey_answered_at
   FROM projects p
     JOIN contributions c ON c.project_id = p.id
     JOIN payments pa ON c.id = pa.contribution_id
     JOIN users u ON c.user_id = u.id
     LEFT JOIN rewards r ON r.id = c.reward_id
     LEFT JOIN "1".surveys su ON su.contribution_id = c.id
  WHERE is_owner_or_admin(c.user_id);
    SQL
  end
end
