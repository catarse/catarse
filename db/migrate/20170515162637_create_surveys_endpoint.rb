class CreateSurveysEndpoint < ActiveRecord::Migration
  def change
    execute %Q{
    CREATE OR REPLACE VIEW "1".surveys AS 
    SELECT s.id as survey_id,
      p.id as project_id,
      s.reward_id,
      s.confirm_address,
      s.sent_at,
      s.finished_at,
      ( SELECT json_agg(open_questions.*) AS json_agg
             FROM ( SELECT 
                      soq.id,
                      soq.question,
                      soq.description
                     FROM survey_open_questions soq
                    WHERE (soq.survey_id = s.id)) open_questions) AS open_questions,
      ( SELECT json_agg(m_questions.*) AS json_agg
             FROM ( SELECT 
                      smcq.id,
                      smcq.question,
                      ( SELECT json_agg(question_choices.*) AS choice_json_agg
                         FROM ( SELECT sqc.id, sqc.option
                         FROM survey_question_choices sqc
                        WHERE (sqc.survey_multiple_choice_question_id = smcq.id)) question_choices) AS question_choices,
                      smcq.description
                     FROM survey_multiple_choice_questions smcq
                    WHERE (smcq.survey_id = s.id)) m_questions) AS multiple_choice_questions
   FROM surveys s join rewards r on r.id = s.reward_id
    join projects p on p.id = r.project_id ;
  }
  end
end
