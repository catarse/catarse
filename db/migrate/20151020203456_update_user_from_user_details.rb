class UpdateUserFromUserDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.update_user_from_user_details() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE public.users
        SET deactivated_at = new.deactivated_at
        WHERE id = old.id AND is_owner_or_admin(old.id);
        RETURN new;
      END;
    $$;

    CREATE TRIGGER update_user_from_user_details
    INSTEAD OF UPDATE ON "1".user_details
    FOR EACH ROW EXECUTE PROCEDURE
    public.update_user_from_user_details();

    GRANT UPDATE (deactivated_at) ON "1".user_details, public.users TO admin;
    GRANT SELECT on public.users to admin;
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION public.update_user_from_user_details() CASCADE;
    SQL
  end
end
