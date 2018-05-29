class AddWelcomeNotificationToRewardDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
  CREATE OR REPLACE VIEW "1"."reward_details" AS 
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
    s.sent_at AS survey_sent_at,
    s.finished_at AS survey_finished_at,
    r.common_id,
    CASE WHEN is_owner_or_admin((select user_id from projects p where p.id = r.project_id))
        THEN r.welcome_message_subject
        else ''::text
    end as welcome_message_subject,
    CASE WHEN is_owner_or_admin((select user_id from projects p where p.id = r.project_id))
        THEN r.welcome_message_body
        else ''::text
    end as welcome_message_body
   FROM (rewards r
     LEFT JOIN surveys s ON ((s.reward_id = r.id)));
    SQL
  end

  def down
    execute <<-SQL
  CREATE OR REPLACE VIEW "1"."reward_details" AS 
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
    s.sent_at AS survey_sent_at,
    s.finished_at AS survey_finished_at,
    r.common_id
   FROM (rewards r
     LEFT JOIN surveys s ON ((s.reward_id = r.id)));
    SQL
  end
end
