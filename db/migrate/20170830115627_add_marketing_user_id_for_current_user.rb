class AddMarketingUserIdForCurrentUser < ActiveRecord::Migration
  def up
    execute %Q{
DROP VIEW "1".mail_marketing_lists;
CREATE OR REPLACE VIEW "1"."mail_marketing_lists" AS 
SELECT mml.id,
    coalesce(mmu.user_id, 0) as user_id,
    mmu.id as marketing_user_id,
    mml.provider,
    mml.label,
    mml.description,
    mml.list_id
   FROM mail_marketing_lists mml
    LEFT JOIN mail_marketing_users mmu on mmu.mail_marketing_list_id = mml.id
        AND is_owner_or_admin(mmu.user_id)
  WHERE (mml.disabled_at IS NULL);
grant select on "1".mail_marketing_lists to anonymous, web_user, admin;

}
  end

  def down
    execute %Q{
drop view "1".mail_marketing_lists;
CREATE OR REPLACE VIEW "1"."mail_marketing_lists" AS
 SELECT mml.id,
    mml.provider,
    mml.label,
    mml.description,
    mml.list_id,
        CASE
            WHEN ("current_user"() = 'anonymous'::name) THEN false
            ELSE COALESCE(( SELECT true AS bool
               FROM mail_marketing_users mmu
              WHERE ((mmu.user_id = current_user_id()) AND (mmu.mail_marketing_list_id = mml.id))), false)
        END AS in_list
   FROM mail_marketing_lists mml
  WHERE (mml.disabled_at IS NULL);
grant select on "1".mail_marketing_lists to admin, web_user, anonymous;
}
  end
end
