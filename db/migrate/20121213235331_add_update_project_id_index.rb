class AddUpdateProjectIdIndex < ActiveRecord::Migration
  def up
    add_index :updates, :project_id
  end

  def down
    remove_index :updates, :project_id
  end
end
