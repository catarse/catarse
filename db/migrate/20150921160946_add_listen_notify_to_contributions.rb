class AddListenNotifyToContributions < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace function public.notify_about_confirmed_payments() returns trigger
      language plpgsql as $$
        declare
          v_contribution json;
        begin
          v_contribution := (select
              json_build_object(
                'user_image', u.profile_img_thumbnail,
                'user_name', u.name,
                'project_image', p.img_thumbnail,
                'project_name', p.name)
              from contributions c
              join users u on u.id = c.user_id
              join projects p on p.id = c.project_id
              where not c.anonymous and c.id = new.contribution_id);

          if v_contribution is not null then
            perform pg_notify('new_paid_contributions', v_contribution::text);
          end if;

          return null;
        end;
      $$;


      create trigger notify_about_confirmed_payments after update of state on public.payments
      for each row
      when (old.state <> 'paid' and new.state = 'paid')
      execute procedure public.notify_about_confirmed_payments();
    SQL
  end

  def down
    execute <<-SQL
      drop function public.notify_about_confirmed_payments() cascade;
    SQL
  end
end
