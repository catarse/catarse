class CreateConfirmedBackersIndex < ActiveRecord::Migration
  def self.up
    execute "
    CREATE INDEX index_confirmed_backers_on_project_id ON backers (project_id) WHERE confirmed;
    "
  end

  def self.down
    execute "
    DROP INDEX index_confirmed_backers_on_project_id;
    "
  end
end
