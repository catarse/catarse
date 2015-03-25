class MigrateFullName < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE users set name = full_name where full_name is not null;
    SQL
    remove_column :users, :full_name
  end
end
