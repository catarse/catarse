class FixApiPermission < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    grant select on public.payments to web_user;
    SQL
  end
end
