class FixCategoryFollowersEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.insert_category_followers()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        declare
          follow "1".category_followers;
        begin
          select
            c.category_id,
            c.user_id
          from public.category_followers c
          where
            c.user_id = current_user_id()
            and c.category_id = NEW.category_id
          into follow;

          if found then
            return follow;
          end if;

          insert into public.category_followers (user_id, category_id)
          values (current_user_id(), NEW.category_id);

          return new;
        end;
      $function$;

CREATE OR REPLACE FUNCTION public.delete_category_followers()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        begin
          delete from public.category_followers 
          where 
            user_id = current_user_id()
            and category_id = OLD.category_id;
          return old;
        end;
      $function$;

CREATE TRIGGER delete_category_followers INSTEAD OF DELETE 
ON "1".category_followers FOR EACH ROW 
EXECUTE PROCEDURE public.delete_category_followers();

GRANT SELECT,INSERT, DELETE ON public.category_followers TO admin, web_user;
GRANT USAGE ON SEQUENCE category_followers_id_seq TO admin, web_user;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.insert_category_followers()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        declare
          follow "1".category_followers;
        begin
          select
            c.category_id,
            c.user_id
          from public.category_followers c
          where
            c.user_id = current_user_id()
            and c.category_id = NEW.category_id
          into follow;

          if found then
            return follow;
          end if;

          insert into public.category_followers (user_id, category_id)
          values (current_user_id(), NEW.category_id);

          return new;
        end;
      $function$;
    SQL
  end
end
