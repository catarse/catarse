class ValidatePaymentForSoldOutReward < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE FUNCTION public.validate_reward_sold_out()
    RETURNS trigger
    LANGUAGE plpgsql AS $$
    BEGIN
    IF EXISTS(SELECT true FROM public.rewards r JOIN public.contributions c ON c.reward_id = r.id WHERE c.id = new.contribution_id AND r.sold_out) THEN
        RAISE EXCEPTION 'Reward for contribution % in payment % is sold out', new.contribution_id, new.id;
    END IF;
    RETURN new;
    END;
    $$;

    CREATE TRIGGER validate_reward_sold_out
    BEFORE INSERT OR UPDATE OF contribution_id
    ON public.payments
    FOR EACH ROW EXECUTE PROCEDURE public.validate_reward_sold_out();
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION public.validate_reward_sold_out() CASCADE;
    SQL
  end
end
