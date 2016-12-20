class CreateBanksEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    create view "1".banks as
    select id, name, code from banks;
    GRANT SELECT ON "1".banks to admin;
    GRANT SELECT ON "1".banks to web_user;
    GRANT SELECT ON "1".banks to anonymous;
    SQL
  end
end
