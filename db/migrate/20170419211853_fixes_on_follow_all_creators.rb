class FixesOnFollowAllCreators < ActiveRecord::Migration
  def change
    execute %Q{
    grant select on public.contributions to admin, web_user;
CREATE OR REPLACE FUNCTION "1".follow_all_creators()
 RETURNS void
 LANGUAGE sql
AS $function$
        INSERT INTO public.user_follows (user_id, follow_id)
            (
                SELECT
                    distinct
                        current_user_id() as user_id,
                        p.user_id as follow_id
                FROM (
                  public.projects p
                  JOIN public.contributions c ON (c.project_id = p.id)
                  JOIN public.payments pa ON (pa.contribution_id = c.id)
                )
                WHERE (
                  c.user_id = current_user_id()
                  and public.was_confirmed(c.*)
                )
                AND NOT EXISTS(
                    SELECT TRUE
                    FROM public.user_follows ufo
                    WHERE ufo.user_id = current_user_id()
                        AND ufo.follow_id = p.user_id
                )
            );
      $function$

}
  end
end
