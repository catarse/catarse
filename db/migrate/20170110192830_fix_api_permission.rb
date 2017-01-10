class FixApiPermission < ActiveRecord::Migration
  def change
    execute <<-SQL
    grant select on public.payments to web_user;
    SQL
  end
end
