class AddMomentNavigationsView < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE MATERIALIZED VIEW public.moments_navigations AS 
 SELECT moments.id,
    moments.created_at,
    moments.data ->> 'ctrse_sid'::text AS ctrse_sid,
    (moments.data -> 'ga'::text) ->> 'clientId'::text AS ga_client_id,
    ((moments.data -> 'user'::text) ->> 'id'::text)::integer AS user_id,
    COALESCE(((moments.data -> 'project'::text) ->> 'id'::text)::integer,
        CASE
            WHEN (moments.data ->> 'label'::text) ~ '^(/(en|pt))?/projects/(\d+)($|/.*)'::text THEN regexp_replace(moments.data ->> 'label'::text, '^(/(en|pt))?/projects/(\d+)($|/.*)'::text, '\3'::text)::integer
            ELSE
            CASE
                WHEN (moments.data ->> 'label'::text) !~* '^/((en|pt)/)?($|login/?|explore/?|sign_up/?|start/?)'::text THEN ( SELECT p.id
                   FROM projects p
                  WHERE lower(p.permalink) = lower(regexp_replace(regexp_replace(moments.data ->> 'label'::text, '^/((en|pt)/)?'::text, ''::text), '[/\?].*'::text, ''::text))
                 LIMIT 1)
                ELSE NULL::integer
            END
        END) AS project_id,
    moments.data ->> 'action'::text AS action,
    lower(moments.data ->> 'label'::text) AS label,
    moments.data ->> 'value'::text AS value,
        CASE
            WHEN (moments.data ->> 'label'::text) = ANY (ARRAY['/'::text, '/en'::text, '/pt'::text]) THEN '/'::text
            ELSE regexp_replace(lower(moments.data ->> 'label'::text), '(^/(pt|en))|(/$)'::text, ''::text)
        END AS path,
    regexp_replace((moments.data -> 'request'::text) ->> 'domain'::text, 'https?:\/\/([^\/\?#]+).*'::text, '\1'::text) AS req_domain,
    regexp_replace((moments.data -> 'request'::text) ->> 'referrer'::text, 'https?:\/\/([^\/\?#]+).*'::text, '\1'::text) AS req_referrer_domain,
    (moments.data -> 'request'::text) ->> 'pathname'::text AS req_pathname,
    (moments.data -> 'request'::text) ->> 'referrer'::text AS req_referrer,
    ((moments.data -> 'request'::text) -> 'query'::text) ->> 'campaign'::text AS req_campaign,
    ((moments.data -> 'request'::text) -> 'query'::text) ->> 'source'::text AS req_source,
    ((moments.data -> 'request'::text) -> 'query'::text) ->> 'medium'::text AS req_medium,
    ((moments.data -> 'request'::text) -> 'query'::text) ->> 'content'::text AS req_content,
    ((moments.data -> 'request'::text) -> 'query'::text) ->> 'term'::text AS req_term,
    ((moments.data -> 'request'::text) -> 'query'::text) ->> 'ref'::text AS req_ref,
    (moments.data -> 'origin'::text) ->> 'domain'::text AS origin_domain,
    (moments.data -> 'origin'::text) ->> 'referrer'::text AS origin_referrer,
    (moments.data -> 'origin'::text) ->> 'campaign'::text AS origin_campaign,
    (moments.data -> 'origin'::text) ->> 'source'::text AS origin_source,
    (moments.data -> 'origin'::text) ->> 'medium'::text AS origin_medium,
    (moments.data -> 'origin'::text) ->> 'content'::text AS origin_content,
    (moments.data -> 'origin'::text) ->> 'term'::text AS origin_term,
    (moments.data -> 'origin'::text) ->> 'ref'::text AS origin_ref,
    moments.data ->> 'request'::text AS request,
    moments.data ->> 'origin'::text AS origin
   FROM moments
  WHERE (moments.data ->> 'category'::text) = 'navigation'::text
WITH NO DATA;

CREATE INDEX moments_navigations_createdat_idx
  ON public.moments_navigations
  USING btree
  (created_at);

CREATE UNIQUE INDEX moments_navigations_idx
  ON public.moments_navigations
  USING btree
  (id);

CREATE INDEX moments_navigations_path_idx
  ON public.moments_navigations
  USING btree
  (path COLLATE pg_catalog."default");

CREATE INDEX moments_navigations_projectid_idx
  ON public.moments_navigations
  USING btree
  (project_id);

CREATE INDEX moments_navigations_projectid_path_idx
  ON public.moments_navigations
  USING btree
  (project_id, path COLLATE pg_catalog."default");

    SQL
  end

  def down
    execute <<-SQL
 DROP MATERIALIZED VIEW public.moments_navigations;
    SQL
  end
end
