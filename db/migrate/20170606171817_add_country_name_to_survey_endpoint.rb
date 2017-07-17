class AddCountryNameToSurveyEndpoint < ActiveRecord::Migration
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
                     LEFT JOIN survey_open_question_answers sa ON sa.contribution_id = c.id
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
                     LEFT JOIN survey_multiple_choice_question_answers sa ON sa.contribution_id = c.id
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
    SQL
  end
end
