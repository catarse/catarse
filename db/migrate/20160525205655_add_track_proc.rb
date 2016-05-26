class AddTrackProc < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE FUNCTION "1".track(event jsonb) RETURNS public.moments
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_moment public.moments;
        BEGIN
            INSERT INTO public.moments(data) VALUES (event) RETURNING * INTO v_moment;

            RETURN v_moment;
        END;
    $$;

GRANT EXECUTE ON FUNCTION "1".track(event jsonb) TO anonymous, web_user, admin;
GRANT INSERT, SELECT ON public.moments TO anonymous, web_user, admin;
GRANT USAGE ON SEQUENCE moments_id_seq TO anonymous, web_user, admin;

ALTER TABLE public.moments
    ADD CONSTRAINT action_not_null check((data->>'action')::text is not null);
    }
  end

  def down
    execute %{
DROP FUNCTION "1".track(event jsonb);
ALTER TABLE public.moments DROP CONSTRAINT action_not_null;
    }
  end
end
