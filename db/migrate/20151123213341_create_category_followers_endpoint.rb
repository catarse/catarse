class CreateCategoryFollowersEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".category_followers AS
    SELECT
        c.category_id,
        c.user_id
    FROM category_followers c
    WHERE
        is_owner_or_admin(c.user_id);
    grant select, insert, delete on "1".category_followers to admin;
    grant select, insert, delete on "1".category_followers to web_user;

      create or replace function public.insert_category_followers() returns trigger
      language plpgsql as $$
        declare
          follow "1".category_followers;
        begin
          select
            c.category_id,
            c.user_id
          from public.category_followers c
          where
            c.user_id = current_userr_id()
            and c.category_id = NEW.category_id
          into follow;

          if found then
            return follow;
          end if;

          insert into public.category_followers (user_id, category_id)
          values (current_user_id(), NEW.category_id);

          return new;
        end;
      $$;

      create trigger insert_category_followers instead of insert on "1".category_followers
        for each row execute procedure public.insert_category_followers();
    SQL
  end
end
