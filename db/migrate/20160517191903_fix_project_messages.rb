class FixProjectMessages < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".direct_messages AS 
        SELECT dm.user_id, dm.to_user_id, dm.project_id, dm.from_email, dm.from_name, dm.content
        from direct_messages dm WHERE is_owner_or_admin(dm.to_user_id);

        grant  select on "1".direct_messages to anonymous ;
        grant  select on "1".direct_messages to web_user ;
    SQL

  end
end
