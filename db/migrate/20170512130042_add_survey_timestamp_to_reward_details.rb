class AddSurveyTimestampToRewardDetails < ActiveRecord::Migration
  def change
    execute <<-SQL
    create or replace view "1".reward_details as
    SELECT r.id,
    r.project_id,
    r.description,
    r.minimum_value,
    r.maximum_contributions,
    r.deliver_at,
    r.updated_at,
    paid_count(r.*) AS paid_count,
    waiting_payment_count(r.*) AS waiting_payment_count,
    r.shipping_options,
    r.row_order,
    r.title,
    s.sent_at  AS survey_sent_at,
    s.finished_at AS survey_finished_at
   FROM rewards r
   LEFT JOIN surveys s on s.reward_id = r.id;
   SQL
  end
end
