class FollowAllCreatorsRpc < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace function "1".follow_all_creators() RETURNS void
      LANGUAGE SQL
      AS $$
        INSERT INTO public.user_follows (user_id, follow_id)
            (
                SELECT
                    distinct
                        current_user_id() as user_id,
                        p.user_id as follow_id
                FROM (
                  projects p
                  JOIN contributions c ON (c.project_id = p.id)
                  JOIN payments pa ON (pa.contribution_id = c.id)
                )
                WHERE (
                  c.user_id = current_user_id()
                  and pa.state = 'paid'
                  and p.state = 'successful'
                )
                AND NOT EXISTS(
                    SELECT TRUE
                    FROM public.user_follows ufo
                    WHERE ufo.user_id = current_user_id()
                        AND ufo.follow_id = p.user_id
                )
            );
      $$;

      grant execute on function "1".follow_all_creators() to admin, web_user;
    SQL
  end
  def down
    execute %Q{
      DROP FUNCTION "1".follow_all_creators();
    }
  end
end
