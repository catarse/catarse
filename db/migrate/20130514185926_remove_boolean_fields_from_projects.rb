class RemoveBooleanFieldsFromProjects < ActiveRecord::Migration
  def up
    execute "
    ALTER TABLE projects DROP IF EXISTS can_finish;
    ALTER TABLE projects DROP IF EXISTS finished;
    ALTER TABLE projects DROP IF EXISTS visible;
    ALTER TABLE projects DROP IF EXISTS rejected;
    ALTER TABLE projects DROP IF EXISTS successful;"
  end

  def down
    add_column :projects, :can_finish, :boolean, default: false
    add_column :projects, :finished, :boolean, default: false
    add_column :projects, :visible, :boolean, default: false
    add_column :projects, :rejected, :boolean, default: false
    add_column :projects, :successful, :boolean, default: false
  end
end
