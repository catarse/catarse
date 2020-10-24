class AddGrantsToUserCredits < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL

      revoke select on "1".user_credits from anonymous;
      grant select on "1".user_credits to admin;
      grant select on "1".user_credits to web_user;
    SQL
  end
end
