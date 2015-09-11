class FixFtiOnContributionDetailsUpdate < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.update_from_details_to_contributions() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
      BEGIN
       -- Prevent mutiple updates
       IF EXISTS (
        SELECT true 
        FROM api_updates.contributions c 
        WHERE c.contribution_id <> OLD.id AND transaction_id = txid_current()
       ) THEN
        RAISE EXCEPTION 'Just one contribution update is allowed per transaction';
       END IF;
       INSERT INTO api_updates.contributions 
        (contribution_id, user_id, reward_id, transaction_id, updated_at)
       VALUES
        (OLD.id, OLD.user_id, OLD.reward_id, txid_current(), now());

       UPDATE public.contributions
       SET 
        user_id = new.user_id,
        reward_id = new.reward_id 
       WHERE id = old.contribution_id;

       -- Just to update FTI
       UPDATE public.payments SET key = key WHERE contribution_id = old.contribution_id;

       -- Return updated record
       SELECT * FROM "1".contribution_details cd WHERE cd.id = old.id INTO new;
       RETURN new;
      END;
    $$;
    SQL
  end
end
