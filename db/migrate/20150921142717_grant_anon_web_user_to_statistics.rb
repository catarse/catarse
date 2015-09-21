class GrantAnonWebUserToStatistics < ActiveRecord::Migration
  def up
    execute <<-SQL
      grant select on "1".statistics to admin;
      grant select on "1".statistics to web_user;
      grant select on "1".statistics to anonymous;
    SQL
  end
  def down
    execute <<-SQL
      revoke select on "1".statistics from web_user;
      revoke select on "1".statistics from anonymous;
    SQL
  end
end
