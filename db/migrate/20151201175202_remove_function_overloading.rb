class RemoveFunctionOverloading < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.is_past(expires_at timestamp without time zone)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT COALESCE(current_timestamp > expires_at, false);
$function$;

DROP FUNCTION public.is_expired(timestamp);

CREATE OR REPLACE FUNCTION public.is_expired(project "1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT public.is_past($1.expires_at);
$function$;

CREATE OR REPLACE FUNCTION public.is_expired(project public.projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT public.is_past($1.expires_at);
$function$;

CREATE OR REPLACE FUNCTION public.is_current_and_online(expires_at timestamp without time zone, state text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT (not public.is_past(expires_at) AND state = 'online');
$function$;

DROP FUNCTION public.open_for_contributions(timestamp, text);

CREATE OR REPLACE FUNCTION public.open_for_contributions(projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT public.is_current_and_online($1.expires_at, COALESCE((SELECT fp.state FROM flexible_projects fp WHERE fp.project_id = $1.id), $1.state));
$function$;

CREATE OR REPLACE FUNCTION "1".project_search(query text)
 RETURNS SETOF "1".projects
 LANGUAGE sql
 STABLE
AS $function$
SELECT
    p.*
FROM
    "1".projects p
WHERE
    (
        p.full_text_index @@ to_tsquery('portuguese', unaccent(query))
        OR
        p.project_name % query
    )
    AND p.state_order >= 'published'
ORDER BY
    public.is_current_and_online(p.expires_at, p.state) DESC,
    p.state_order,
    ts_rank(p.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    p.project_id DESC;
$function$;

GRANT SELECT ON public.flexible_projects TO PUBLIC;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.is_expired(expires_at timestamp without time zone)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT COALESCE(current_timestamp > expires_at, false);
$function$;

DROP FUNCTION public.is_past(timestamp);

CREATE OR REPLACE FUNCTION public.is_expired(project "1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
    SELECT public.is_expired($1.expires_at);
$function$;

CREATE OR REPLACE FUNCTION public.is_expired(project public.projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
    SELECT public.is_expired($1.expires_at);
$function$;

CREATE OR REPLACE FUNCTION public.open_for_contributions(expires_at timestamp without time zone, state text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
    SELECT (not public.is_expired(expires_at) AND state = 'online');
$function$;

DROP FUNCTION public.is_current_and_online(timestamp, text);

CREATE OR REPLACE FUNCTION public.open_for_contributions(projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
    SELECT public.open_for_contributions($1.expires_at, COALESCE((SELECT fp.state FROM flexible_projects fp WHERE fp.project_id = $1.id), $1.state));
$function$;
    SQL
  end
end
