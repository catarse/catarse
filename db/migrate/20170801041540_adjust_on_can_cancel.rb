class AdjustOnCanCancel < ActiveRecord::Migration
  def change
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
