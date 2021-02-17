class AdjustIsExpiredToNotLookOverFixedDays < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.is_expired(project projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
            select
            case when $1.mode = 'sub' then
               false
            else
              public.is_past($1.expires_at)
            end;
        $function$
;
---

CREATE OR REPLACE FUNCTION public.is_expired(project "1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$ 
            select
            case when $1.mode = 'sub' then
               false
            else
              public.is_past($1.expires_at)
            end;
        $function$

    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.is_expired(project projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
            select
            case when $1.mode = 'aon' then
               public.is_past($1.expires_at)
            when $1.mode = 'sub' then
               false
            else
              public.is_past($1.expires_at) OR current_timestamp > $1.online_at + '365 days'::interval
            end;
        $function$
;
---

CREATE OR REPLACE FUNCTION public.is_expired(project "1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$ 
            select
            case when $1.mode = 'aon' then
               public.is_past($1.expires_at)
            when $1.mode = 'sub' then
               false
            else
              public.is_past($1.expires_at) OR current_timestamp > $1.online_date + '365 days'::interval
            end;
        $function$

    SQL
  end
end
