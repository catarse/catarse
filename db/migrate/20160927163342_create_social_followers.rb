class CreateSocialFollowers < ActiveRecord::Migration
  def up
  execute %Q{
    CREATE SEQUENCE public.social_followers_id_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    CREATE TYPE social_followers_types AS ENUM ('tw', 'fb_profile', 'fb_page', 'fb_group');

    CREATE TABLE public.social_followers
    (
      id integer NOT NULL DEFAULT nextval('social_followers_id_seq'::regclass),
      user_id integer NOT NULL,
      profile_type social_followers_types NOT NULL,
      username character varying(1024) NOT NULL,
      followers integer NOT NULL,
      created_at timestamp without time zone NOT NULL DEFAULT now(),
      CONSTRAINT social_followers_user_id_reference FOREIGN KEY (user_id)
          REFERENCES public.users (id) MATCH SIMPLE
          ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT followersck CHECK (followers >= 0)
    )
  }
  end
  def down
  execute %Q{
    DROP TYPE social_followers_types;
    DROP TABLE public.social_followers;
    DROP SEQUENCE public.social_followers_id_seq;
  }
  end
end
