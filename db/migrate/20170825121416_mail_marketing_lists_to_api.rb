class MailMarketingListsToApi < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view "1".mail_marketing_lists as 
    select
        mml.id as id,
        mmu.user_id as user_id,
        mml.provider as provider,
        mml.label as label,
        mml.list_id as list_id
    from public.mail_marketing_users mmu
        join public.mail_marketing_lists mml on mml.id = mmu.mail_marketing_list_id
    where public.is_owner_or_admin(mmu.user_id) and mml.disabled_at is null;
grant select on public.mail_marketing_lists to admin, web_user;
grant select on public.mail_marketing_users to admin, web_user;
grant select on "1".mail_marketing_lists to admin, web_user;
}
  end

  def down
    execute %Q{
drop view "1".mail_marketing_lists;
}
  end
end
