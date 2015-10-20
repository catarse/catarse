class RemoveRewardFromContributionDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
SET statement_timeout TO 0;
    SQL
    execute <<-SQL
DROP VIEW "1".contribution_details;
CREATE VIEW "1".contribution_details AS
 SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.user_id,
    c.project_id,
    c.reward_id,
    p.permalink,
    p.name AS project_name,
    thumbnail_image(p.*) AS project_img,
    p.online_date AS project_online_date,
    p.expires_at AS project_expires_at,
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
    pa.created_at,
    pa.created_at AS pending_at,
    pa.paid_at,
    pa.refused_at,
    pa.pending_refund_at,
    pa.refunded_at,
    pa.deleted_at,
    pa.chargeback_at,
    pa.full_text_index,
    waiting_payment(pa.*) AS waiting_payment
   FROM projects p
     JOIN contributions c ON c.project_id = p.id
     JOIN payments pa ON c.id = pa.contribution_id
     JOIN users u ON c.user_id = u.id;

CREATE TRIGGER update_from_details_to_contributions INSTEAD OF UPDATE ON "1".contribution_details FOR EACH ROW EXECUTE PROCEDURE public.update_from_details_to_contributions();

GRANT SELECT,UPDATE ON TABLE "1".contribution_details TO admin;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".contribution_details;
CREATE VIEW "1".contribution_details AS
 SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.user_id,
    c.project_id,
    c.reward_id,
    p.permalink,
    p.name AS project_name,
    thumbnail_image(p.*) AS project_img,
    p.online_date AS project_online_date,
    p.expires_at AS project_expires_at,
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
    pa.created_at,
    pa.created_at AS pending_at,
    pa.paid_at,
    pa.refused_at,
    pa.pending_refund_at,
    pa.refunded_at,
    pa.deleted_at,
    pa.chargeback_at,
    pa.full_text_index,
    waiting_payment(pa.*) AS waiting_payment,
    ( SELECT row_to_json(r.*) AS row_to_json
           FROM reward_details r
          WHERE r.id = c.reward_id) AS reward
   FROM projects p
     JOIN contributions c ON c.project_id = p.id
     JOIN payments pa ON c.id = pa.contribution_id
     JOIN users u ON c.user_id = u.id;

CREATE TRIGGER update_from_details_to_contributions INSTEAD OF UPDATE ON "1".contribution_details FOR EACH ROW EXECUTE PROCEDURE public.update_from_details_to_contributions();

GRANT SELECT,UPDATE ON TABLE "1".contribution_details TO admin;
    SQL
  end
end
