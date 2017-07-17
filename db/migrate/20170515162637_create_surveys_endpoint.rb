class CreateSurveysEndpoint < ActiveRecord::Migration
  def change
    execute %Q{
    CREATE OR REPLACE VIEW "1".surveys AS 
    SELECT s.id as survey_id,
      c.project_id as project_id,
      c.id as contribution_id,
      s.reward_id,
      s.confirm_address,
      s.sent_at,
      s.finished_at,
      ( SELECT json_agg(open_questions.*) AS json_agg
             FROM ( SELECT 
                      soq.id,
                      soq.question,
                      soq.description,
                      sa.answer,
                      sa.created_at as answered_at
                     FROM survey_open_questions soq
                      LEFT JOIN survey_open_question_answers sa ON sa.contribution_id = c.id
                    WHERE (soq.survey_id = s.id)) open_questions) AS open_questions,
      ( SELECT json_agg(m_questions.*) AS json_agg
             FROM ( SELECT 
                      smcq.id,
                      smcq.question,
                      sa.survey_question_choice_id,
                      sa.created_at as answered_at,
                      ( SELECT json_agg(question_choices.*) AS choice_json_agg
                         FROM ( SELECT sqc.id, sqc.option
                         FROM survey_question_choices sqc
                        WHERE (sqc.survey_multiple_choice_question_id = smcq.id)) question_choices) AS question_choices,
                      smcq.description
                     FROM survey_multiple_choice_questions smcq
                      LEFT JOIN survey_multiple_choice_question_answers sa ON sa.contribution_id = c.id
                    WHERE (smcq.survey_id = s.id)) m_questions) AS multiple_choice_questions
   FROM contributions c right join surveys s on s.reward_id = c.reward_id;
  }
  end
end
