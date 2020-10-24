class ProjectVisitorsPerDayViewWithoutMaterialized < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
DROP MATERIALIZED VIEW "1".project_visitors_per_day;

CREATE OR REPLACE FUNCTION public.moments_project_identifier_from_label(label text)
RETURNS text
LANGUAGE 'sql'
IMMUTABLE
AS $BODY$
SELECT
	CASE
		WHEN label ~ '^(/(en|pt))?/projects/(\d+)($|/.*)'
		THEN regexp_replace(label,'^(/(en|pt))?/projects/(\d+)($|/.*)', '\3')
	ELSE
	CASE
		WHEN label !~* '^/((en|pt)/)?($|\?|\#|((login|explore|sign_up|start|users|projects|flexible_projects)(/|$|\?|\#)))'
		THEN lower(regexp_replace(regexp_replace(label, '^/((en|pt)/)?', ''), '[/\?\#].*', ''))
	ELSE NULL::text
	END END
$BODY$;

CREATE OR REPLACE FUNCTION public.moments_projectid_from_label(label text)
RETURNS integer
LANGUAGE 'plpgsql'
STABLE
AS $BODY$
DECLARE
	identifier text := public.moments_project_identifier_from_label(label);
BEGIN
	IF identifier is null or identifier ~ '^\d+$'
		THEN RETURN identifier::integer;
	END IF;

    RETURN (SELECT p.id
            FROM projects p
            WHERE lower(p.permalink) = identifier
            LIMIT 1)::integer;
EXCEPTION
WHEN NUMERIC_VALUE_OUT_OF_RANGE THEN
	RETURN (SELECT p.id
            FROM projects p
            WHERE lower(p.permalink) = identifier
            LIMIT 1)::integer;
END
$BODY$;


CREATE TABLE public.moments_navigation_projects_tbl
(
    moment_id integer,
    created_at timestamp without time zone,
    ctrse_sid text COLLATE pg_catalog."default",
    ga_client_id text COLLATE pg_catalog."default",
    user_id integer,
    project_id integer,
    action text COLLATE pg_catalog."default",
    label text COLLATE pg_catalog."default",
    value text COLLATE pg_catalog."default",
    path text COLLATE pg_catalog."default",
    req_domain text COLLATE pg_catalog."default",
    req_referrer_domain text COLLATE pg_catalog."default",
    req_pathname text COLLATE pg_catalog."default",
    req_referrer text COLLATE pg_catalog."default",
    req_campaign text COLLATE pg_catalog."default",
    req_source text COLLATE pg_catalog."default",
    req_medium text COLLATE pg_catalog."default",
    req_content text COLLATE pg_catalog."default",
    req_term text COLLATE pg_catalog."default",
    req_ref text COLLATE pg_catalog."default",
    origin_domain text COLLATE pg_catalog."default",
    origin_referrer text COLLATE pg_catalog."default",
    origin_campaign text COLLATE pg_catalog."default",
    origin_source text COLLATE pg_catalog."default",
    origin_medium text COLLATE pg_catalog."default",
    origin_content text COLLATE pg_catalog."default",
    origin_term text COLLATE pg_catalog."default",
    origin_ref text COLLATE pg_catalog."default",
    request text COLLATE pg_catalog."default",
    origin text COLLATE pg_catalog."default"
);
CREATE UNIQUE INDEX moments_navigation_projects_tbl_idx
  ON public.moments_navigation_projects_tbl (moment_id);
CREATE INDEX moments_navigation_projects_tbl_createdat_idx
  ON public.moments_navigation_projects_tbl (created_at);
CREATE INDEX moments_navigation_projects_tbl_projectid_idx
  ON public.moments_navigation_projects_tbl (project_id);
CREATE INDEX moments_navigation_projects_tbl_projectid_createdat_idx
  ON public.moments_navigation_projects_tbl (project_id, created_at);
CREATE INDEX moments_navigation_projects_tbl_projectid_createdat_userid_idx
  ON public.moments_navigation_projects_tbl (project_id, created_at, user_id);



CREATE OR REPLACE FUNCTION public.moments_navigation_projects_tbl_refresh()
RETURNS void
    LANGUAGE 'sql'
    VOLATILE
AS $BODY$

INSERT into public.moments_navigation_projects_tbl
 SELECT moments.id,
    moments.created_at,
    moments.data ->> 'ctrse_sid' AS ctrse_sid,
    (moments.data -> 'ga') ->> 'clientId' AS ga_client_id,
    ((moments.data -> 'user') ->> 'id')::integer AS user_id,
    COALESCE(
		((moments.data -> 'project') ->> 'id')::integer,
        public.moments_projectid_from_label((moments.data ->> 'label'))
	) AS project_id,
    moments.data ->> 'action' AS action,
    lower(moments.data ->> 'label') AS label,
    moments.data ->> 'value' AS value,
        CASE
            WHEN (moments.data ->> 'label') = ANY (ARRAY['/', '/en', '/pt']) THEN '/'
            ELSE regexp_replace(lower(moments.data ->> 'label'), '(^/(pt|en))|(/$)', '')
        END AS path,
    regexp_replace((moments.data -> 'request') ->> 'domain', 'https?:\/\/([^\/\?#]+).*', '\1') AS req_domain,
    regexp_replace((moments.data -> 'request') ->> 'referrer', 'https?:\/\/([^\/\?#]+).*', '\1') AS req_referrer_domain,
    (moments.data -> 'request') ->> 'pathname' AS req_pathname,
    (moments.data -> 'request') ->> 'referrer' AS req_referrer,
    ((moments.data -> 'request') -> 'query') ->> 'campaign' AS req_campaign,
    ((moments.data -> 'request') -> 'query') ->> 'source' AS req_source,
    ((moments.data -> 'request') -> 'query') ->> 'medium' AS req_medium,
    ((moments.data -> 'request') -> 'query') ->> 'content' AS req_content,
    ((moments.data -> 'request') -> 'query') ->> 'term' AS req_term,
    ((moments.data -> 'request') -> 'query') ->> 'ref' AS req_ref,
    (moments.data -> 'origin') ->> 'domain' AS origin_domain,
    (moments.data -> 'origin') ->> 'referrer' AS origin_referrer,
    (moments.data -> 'origin') ->> 'campaign' AS origin_campaign,
    (moments.data -> 'origin') ->> 'source' AS origin_source,
    (moments.data -> 'origin') ->> 'medium' AS origin_medium,
    (moments.data -> 'origin') ->> 'content' AS origin_content,
    (moments.data -> 'origin') ->> 'term' AS origin_term,
    (moments.data -> 'origin') ->> 'ref' AS origin_ref,
    moments.data ->> 'request' AS request,
    moments.data ->> 'origin' AS origin
   FROM moments
  WHERE (moments.data ->> 'category') = 'navigation'
    AND moments_project_identifier_from_label((moments.data ->> 'label')) is not null
	AND moments.created_at > coalesce((select max(created_at) from public.moments_navigation_projects_tbl),'20100101')
  ORDER BY moments.created_at

$BODY$;

------------------------
CREATE TABLE public.project_visitors_per_day_tbl
(
    project_id integer,
    day text COLLATE pg_catalog."default",
    visitors bigint
);
CREATE UNIQUE INDEX project_visitors_per_day_tbl_idx
    ON public.project_visitors_per_day_tbl (project_id);
CREATE INDEX project_visitors_per_day_tbl_day_idx
    ON public.project_visitors_per_day_tbl (day);


CREATE OR REPLACE FUNCTION public.project_visitors_per_day_tbl_refresh()
RETURNS void
    LANGUAGE 'sql'
    VOLATILE
AS $BODY$
SELECT public.moments_navigation_projects_tbl_refresh();

--Apaga as entradas de hoje.  Na 9.5 pode trocar pelo UPSET
DELETE FROM public.project_visitors_per_day_tbl
WHERE day >= to_char(zone_timestamp(CURRENT_TIMESTAMP::timestamp without time zone), 'YYYY-MM-DD');

INSERT into public.project_visitors_per_day_tbl
    (SELECT n.project_id,
            to_char(zone_timestamp(n.created_at), 'YYYY-MM-DD') AS day,
            count(DISTINCT n.ctrse_sid) AS visitors
           FROM moments_navigation_projects_tbl n
             JOIN projects p ON p.id = n.project_id
             JOIN project_transitions pt ON pt.project_id = p.id AND pt.to_state = 'online'
             LEFT JOIN LATERAL ( SELECT ptf_1.id,
                    ptf_1.created_at
                   FROM project_transitions ptf_1
                  WHERE ptf_1.project_id = p.id AND (ptf_1.to_state = ANY (ARRAY['waiting_funds'::character varying, 'successful'::character varying, 'failed'::character varying]::text[]))
                  ORDER BY ptf_1.created_at
                 LIMIT 1) ptf ON true
          WHERE n.created_at >= pt.created_at
			AND (ptf.* IS NULL OR n.created_at <= ptf.created_at)
			AND (n.user_id IS NULL OR n.user_id <> p.user_id)
			AND n.path !~ '^/projects/d+/.+'
			AND to_char(zone_timestamp(n.created_at), 'YYYY-MM-DD') > coalesce((select max(day) from public.project_visitors_per_day_tbl),'20100101')
          GROUP BY n.project_id, day
          ORDER BY n.project_id, day)
--  só no PGSQL 9.5
--ON CONFLICT (project_id, day) DO UPDATE SET visitors = EXCLUDED.visitors
;

$BODY$;


------------------------------


CREATE VIEW "1".project_visitors_per_day
AS
 SELECT i.project_id,
    sum(i.visitors) AS total,
    json_agg(json_build_object('day', i.day, 'visitors', i.visitors)) AS source
   FROM public.project_visitors_per_day_tbl i
  GROUP BY i.project_id;

GRANT SELECT ON TABLE "1".project_visitors_per_day TO anonymous;
GRANT SELECT ON TABLE "1".project_visitors_per_day TO web_user;
GRANT SELECT ON TABLE "1".project_visitors_per_day TO admin;




    SQL
  end

  def down
    execute <<-SQL
 DROP VIEW "1".project_visitors_per_day;
 DROP FUNCTION FUNCTION public.project_visitors_per_day_tbl_refresh();
 DROP TABLE public.project_visitors_per_day_tbl;
 DROP FUNCTION public.moments_navigation_projects_tbl_refresh();
 DROP TABLE public.moments_navigation_projects_tbl;
 DROP FUNCTION public.moments_projectid_from_label(label text);
 DROP FUNCTION public.moments_project_identifier_from_label(label text);


 CREATE MATERIALIZED VIEW "1".project_visitors_per_day AS
 select i.project_id, sum(visitors) as total,
     json_agg(json_build_object('day', i.day, 'visitors', i.visitors)) AS source
 from (
   select p.id as project_id,
       to_char(zone_timestamp(n.created_at),'YYYY-MM-DD') as day,
       --count(*) as visitas,
       count(distinct n.ctrse_sid) as visitors
       --count(distinct n.user_id) as visitantes_logados
   from public.moments_navigations n
   join projects p on p.id=n.project_id
   join project_transitions pt on pt.project_id=p.id and pt.to_state='online'
   left join project_transitions ptf on ptf.project_id=p.id and ptf.to_state in ('successful','failed')
   where n.created_at>=pt.created_at and (ptf is null or n.created_at<=ptf.created_at) and (n.user_id is null or n.user_id<>p.user_id) and n.path !~ '^/projects/\d+/.+' --and n.created_at >= now()-'6 days'::interval
   group by p.id, day
   order by p.id, day
 )i
 group by i.project_id
 WITH NO DATA;


 GRANT SELECT ON TABLE "1".project_visitors_per_day TO anonymous;
 GRANT SELECT ON TABLE "1".project_visitors_per_day TO web_user;
 GRANT SELECT ON TABLE "1".project_visitors_per_day TO admin;
     SQL
  end
end
