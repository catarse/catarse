class UpdateUserFromUserFullDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TRIGGER update_user_from_user_details
    INSTEAD OF UPDATE ON "1".user_full_details
    FOR EACH ROW EXECUTE PROCEDURE
    public.update_user_from_user_details();

    GRANT UPDATE (deactivated_at) ON "1".user_full_details, public.users TO admin;
    SQL
  end

  def down
    execute <<-SQL
    DROP TRIGGER update_user_from_user_details ON "1".user_full_details;
    SQL
  end
end
