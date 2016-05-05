class AddUserFollowsApi < ActiveRecord::Migration
  def up
    execute %Q{
ALTER TABLE public.user_follows 
    ADD CONSTRAINT ufollowfk FOREIGN KEY (follow_id) REFERENCES public.users (id);

create or replace view "1".user_follows as
    select
        uf.user_id,
        uf.follow_id,
        json_build_object(
            'name', f.name,
            'avatar', public.thumbnail_image(f.*),
            'total_contributed_projects', ut.total_contributed_projects,
            'total_published_projects', ut.total_published_projects,
            'city', f.address_city,
            'state', f.address_state
        ) as source,
        public.zone_timestamp(uf.created_at) as created_at
    from public.user_follows uf
    left join "1".user_totals ut on ut.user_id = uf.follow_id
    join public.users as f on f.id = uf.follow_id
    where public.is_owner_or_admin(uf.user_id) and f.deactivated_at is null;

GRANT SELECT, INSERT, DELETE ON "1".user_follows TO admin, web_user;
GRANT SELECT, INSERT, DELETE ON public.user_follows TO admin, web_user;
GRANT USAGE ON SEQUENCE user_follows_id_seq TO admin, web_user;

CREATE OR REPLACE FUNCTION public.insert_user_follow() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_follow "1".user_follows;
        BEGIN
            INSERT INTO public.user_follows(user_id, follow_id, created_at) VALUES
                (current_user_id(), NEW.follow_id, now());

            SELECT * FROM "1".user_follows WHERE user_id = current_user_id() AND follow_id = NEW.follow_id
                INTO v_follow;

            RETURN v_follow;
        END;
    $$;

CREATE TRIGGER insert_user_follow INSTEAD OF INSERT ON "1".user_follows 
FOR EACH ROW EXECUTE PROCEDURE public.insert_user_follow();


CREATE OR REPLACE FUNCTION public.delete_user_follow() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_follow "1".user_follows;
        BEGIN
            IF OLD.follow_id IS NULL THEN
                RAISE EXCEPTION 'missing follow';
            END IF;

            DELETE FROM public.user_follows 
                WHERE user_id = current_user_id() AND follow_id = OLD.follow_id;

            RETURN OLD;
        END;
    $$;

CREATE TRIGGER delete_user_follow INSTEAD OF DELETE ON "1".user_follows 
FOR EACH ROW EXECUTE PROCEDURE public.delete_user_follow();
    }
  end

  def down
    execute %Q{
DROP VIEW "1".user_follows;
DROP FUNCTION public.insert_user_follow();
DROP FUNCTION public.delete_user_follow();
ALTER TABLE public.user_follows
    DROP CONSTRAINT ufollowfk;
    }
  end
end
