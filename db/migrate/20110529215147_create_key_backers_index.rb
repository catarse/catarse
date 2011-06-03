class CreateKeyBackersIndex < ActiveRecord::Migration
  def self.up
    execute "
    CREATE INDEX index_backers_on_key ON backers (key);
    "
  end

  def self.down
    execute "
    DROP INDEX index_backers_on_key;
    "
  end
end
