class CreateMomentsViews < ActiveRecord::Migration
  def up
  execute %Q{
CREATE MATERIALIZED VIEW public.moments_project_start AS 
 SELECT moments.id,
    moments.data ->> 'ctrse_sid'::text AS ctrse_sid,
    (moments.data -> 'user'::text) ->> 'id'::text AS user_id,
    moments.data ->> 'action'::text AS action,
    moments.created_at
   FROM public.moments
  WHERE (moments.data ->> 'category'::text) = 'project_start'::text AND (moments.data ->> 'ctrse_sid'::text) IS NOT NULL
  ORDER BY moments.data ->> 'ctrse_sid'::text, moments.created_at
WITH NO DATA;

CREATE UNIQUE INDEX moments_project_start_idx
  ON public.moments_project_start
  USING btree
  (id);


CREATE MATERIALIZED VIEW public.moments_project_start_inferuser AS 
 SELECT t.id,
    t.ctrse_sid,
    t.user_id,
    t.inferred_user_id,
    t.action,
    t.created_at
   FROM ( SELECT m.id,
            m.ctrse_sid,
            m.user_id,
            COALESCE(m.user_id, ( SELECT m2.user_id
                   FROM public.moments_project_start m2
                  WHERE m2.ctrse_sid = m.ctrse_sid AND m2.created_at > m.created_at
                  ORDER BY m2.created_at
                 LIMIT 1))::integer AS inferred_user_id,
            m.action,
            m.created_at
           FROM public.moments_project_start m) t
  WHERE t.inferred_user_id IS NOT NULL
WITH NO DATA;

CREATE UNIQUE INDEX moments_project_start_inferuser_idx
  ON public.moments_project_start_inferuser
  USING btree
  (id);

  }
  end

  def down
  execute %Q{
DROP MATERIALIZED VIEW public.moments_project_start_inferuser;
DROP MATERIALIZED VIEW public.moments_project_start;
  }
  end
end
