class AddSkipFinishToCanCancelFunction < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.can_cancel(p projects)
 RETURNS boolean
 LANGUAGE sql
AS $function$
        select
            CASE
            WHEN p.state in ('draft', 'rejected') THEN false
            WHEN p.skip_finish THEN false
            WHEN p.state = 'successful' AND NOT public.owner_has_balance_for_refund(p.*) THEN false
            ELSE
                true
            END
    $function$
;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.can_cancel(p projects)
 RETURNS boolean
 LANGUAGE sql
AS $function$
        select
            CASE
            WHEN p.state in ('draft', 'rejected') THEN false
            WHEN p.state = 'successful' AND NOT public.owner_has_balance_for_refund(p.*) THEN false
            ELSE
                true
            END
    $function$
;
}
  end
end
