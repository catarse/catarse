class UpdateAnonymousToFalse < ActiveRecord::Migration
  def self.up
    execute("UPDATE backers SET anonymous = false")
  end

  def self.down
  end
end
