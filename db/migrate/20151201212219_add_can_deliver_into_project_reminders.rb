class AddCanDeliverIntoProjectReminders < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.can_deliver(public.project_reminders) returns boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
select exists (
select true from projects p
left join flexible_projects fp on fp.project_id = p.id
where p.expires_at is not null
and p.id = $1.project_id
and coalesce(fp.state, p.state) = 'online'
and public.is_past((p.expires_at - '48 hours'::interval))
and not exists (select true from project_notifications pn
where pn.user_id = $1.user_id and pn.project_id = $1.project_id
and pn.template_name = 'reminder'));
$_$;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION public.can_deliver(public.project_reminders);
    SQL
  end
end
