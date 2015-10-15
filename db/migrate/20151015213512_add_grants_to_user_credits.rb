class AddGrantsToUserCredits < ActiveRecord::Migration
  def change
    execute <<-SQL

      grant select on "1".user_credits to anonymous;
      grant select on "1".user_credits to admin;
      grant select on "1".user_credits to web_user;
    SQL
  end
end
