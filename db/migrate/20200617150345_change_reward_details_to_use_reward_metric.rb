class ChangeRewardDetailsToUseRewardMetric < ActiveRecord::Migration[4.2]
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
    coalesce((rms.data->>'paid_count')::bigint, 0) AS paid_count,
    coalesce((rms.data->>'waiting_payment_count')::bigint, 0) AS waiting_payment_count,
    r.shipping_options,
    r.row_order,
    r.title,
    s.sent_at AS survey_sent_at,
    s.finished_at AS survey_finished_at,
    r.common_id,
        CASE
            WHEN is_owner_or_admin(( SELECT p.user_id
               FROM projects p
              WHERE (p.id = r.project_id))) THEN r.welcome_message_subject
            ELSE ''::text
        END AS welcome_message_subject,
        CASE
            WHEN is_owner_or_admin(( SELECT p.user_id
               FROM projects p
              WHERE (p.id = r.project_id))) THEN r.welcome_message_body
            ELSE ''::text
        END AS welcome_message_body,
    thumbnail_image(r.*) AS uploaded_image,
    r.run_out
   FROM (rewards r
     LEFT JOIN reward_metric_storages rms on ((rms.reward_id = r.id))
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
    r.common_id,
        CASE
            WHEN is_owner_or_admin(( SELECT p.user_id
               FROM projects p
              WHERE (p.id = r.project_id))) THEN r.welcome_message_subject
            ELSE ''::text
        END AS welcome_message_subject,
        CASE
            WHEN is_owner_or_admin(( SELECT p.user_id
               FROM projects p
              WHERE (p.id = r.project_id))) THEN r.welcome_message_body
            ELSE ''::text
        END AS welcome_message_body,
    thumbnail_image(r.*) AS uploaded_image,
    r.run_out
   FROM (rewards r
     LEFT JOIN surveys s ON ((s.reward_id = r.id)));
    SQL
  end
end
