class AddSurveyNotificationEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION "1".sent_survey_count(reward_id integer) RETURNS bigint
      LANGUAGE sql AS $$
      select count(distinct contribution_id) filter (where contribution_id in (select id from contributions where reward_id = $1)) from contribution_notifications where template_name ='answer_survey';
      $$;
      grant execute on function "1".sent_survey_count(integer) to admin, web_user, anonymous;
    SQL
  end
end
