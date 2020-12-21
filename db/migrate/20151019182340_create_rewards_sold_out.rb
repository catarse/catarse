class CreateRewardsSoldOut < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
    CREATE FUNCTION public.sold_out(reward rewards)
    RETURNS boolean LANGUAGE SQL STABLE AS $$
    SELECT reward.paid_count + reward.waiting_payment_count >= reward.maximum_contributions;
    $$;
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION public.sold_out(rewards);
    SQL
  end
end
