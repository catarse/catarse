class UpdateSuccessfulOnProjects < ActiveRecord::Migration
  def self.up
    execute 'UPDATE projects SET successful = false WHERE successful IS NULL'
  end

  def self.down
  end
end
