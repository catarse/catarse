class AdjustMailMarketingListEndpointToUseCurrentUser < ActiveRecord::Migration
  def up
    add_column :mail_marketing_lists, :description, :text
    execute %Q{
drop view "1".mail_marketing_lists;
create or replace view "1".mail_marketing_lists as
    select
        mml.id,
        mml.provider,
        mml.label,
        mml.description,
        mml.list_id,
        (case when current_role = 'anonymous' then false 
         else coalesce((
            select true 
            from mail_marketing_users mmu 
            where mmu.user_id = public.current_user_id() and mmu.mail_marketing_list_id = mml.id
            ), false) end) as in_list
    from mail_marketing_lists mml
        where mml.disabled_at is null;
grant select on "1".mail_marketing_lists to anonymous, admin, web_user;
}
  end

  def down
    remove_column :mail_marketing_lists, :description
    execute %Q{
drop view "1".mail_marketing_lists;
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
grant select on "1".mail_marketing_lists to anonymous, admin, web_user;
}
  end
end
