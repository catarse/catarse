class AddShippingOptionsToRewardDetails < ActiveRecord::Migration
  def change
    execute <<-SQL
 CREATE OR REPLACE VIEW "1".reward_details AS
       SELECT r.id,
          r.project_id,
          r.description,
          r.minimum_value,
          r.maximum_contributions,
          r.deliver_at,
          r.updated_at,
          public.paid_count(r.*) AS paid_count,
          public.waiting_payment_count(r.*) AS waiting_payment_count,
          r.shipping_options as shipping_options
         FROM public.rewards r;
    SQL
  end
end
