class CreateUpdateRuleForContributionDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE SCHEMA api_updates;
    CREATE TABLE api_updates.contributions (
      transaction_id bigint, 
      updated_at timestamp,
      contribution_id int, 
      user_id int, 
      reward_id int,
      PRIMARY KEY (transaction_id, updated_at)
    );
    CREATE OR REPLACE FUNCTION public.update_from_details_to_contributions() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
      BEGIN
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
       SELECT * FROM "1".contribution_details cd WHERE cd.id = old.id INTO new;
       RETURN new;
      END;
    $$;

    CREATE TRIGGER update_from_details_to_contributions 
    INSTEAD OF UPDATE ON "1".contribution_details 
    FOR EACH ROW EXECUTE PROCEDURE 
    public.update_from_details_to_contributions();
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION public.update_from_details_to_contributions() CASCADE;
    DROP SCHEMA api_updates CASCADE;
    SQL
  end
end
