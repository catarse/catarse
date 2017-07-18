class CreateMomentsProjectPageviews < ActiveRecord::Migration
  def up
    execute %Q{
CREATE MATERIALIZED VIEW public.moments_project_pageviews AS 
 SELECT m.id,
    ((m.data -> 'project'::text) ->> 'id'::text)::integer AS project_id,
    m.data ->> 'ctrse_sid'::text AS ctrse_sid,
    ((m.data -> 'user'::text) ->> 'id'::text)::integer AS user_id,
    m.created_at AS visited_at
   FROM moments m
  WHERE (m.data ->> 'category'::text) = 'project_view'::text AND (m.data ->> 'action'::text) = 'project_page_view'::text AND ((m.data -> 'project'::text) ->> 'id'::text) ~ '^\d+$'::text
WITH NO DATA;
CREATE INDEX moments_project_pageviews_ctrsesid_userid
  ON public.moments_project_pageviews
  USING btree (ctrse_sid COLLATE pg_catalog."default", user_id)
  WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX moments_project_pageviews_idx
  ON public.moments_project_pageviews
  USING btree (id);
CREATE INDEX moments_project_pageviews_projectid
  ON public.moments_project_pageviews
  USING btree (project_id);
CREATE INDEX moments_project_pageviews_userid
  ON public.moments_project_pageviews
  USING btree (user_id);

CREATE MATERIALIZED VIEW public.moments_project_pageviews_inferuser AS 
 SELECT m.id,
    m.project_id,
    m.ctrse_sid,
    COALESCE(m.user_id, ( SELECT m2.user_id
           FROM moments_project_pageviews m2
          WHERE m2.ctrse_sid = m.ctrse_sid AND m2.user_id IS NOT NULL AND m2.visited_at > m.visited_at
         LIMIT 1)) AS user_id,
    m.visited_at
   FROM moments_project_pageviews m
WITH NO DATA;
CREATE UNIQUE INDEX moments_project_pageviews_inferuser_idx
  ON public.moments_project_pageviews_inferuser
  USING btree (id);
CREATE INDEX moments_project_pageviews_inferuser_projectid
  ON public.moments_project_pageviews_inferuser
  USING btree (project_id);
CREATE INDEX moments_project_pageviews_inferuser_projectid_userid
  ON public.moments_project_pageviews_inferuser
  USING btree (project_id, user_id)
  WHERE user_id IS NOT NULL;
CREATE INDEX moments_project_pageviews_inferuser_userid
  ON public.moments_project_pageviews_inferuser
  USING btree (user_id);
    }
  end

  def down
    execute %Q{
        DROP MATERIALIZED VIEW public.moments_project_pageviews_inferuser;
        DROP MATERIALIZED VIEW public.moments_project_pageviews;
    }
  end
end
