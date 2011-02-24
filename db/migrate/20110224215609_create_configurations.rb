require 'sexy_pg_constraints'
class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.text :name, :null => false
      t.text :value
      t.timestamps
    end
    constrain :configurations do |t|
      t.name :not_blank => true
    end
  end
  def self.down
    drop_table :configurations
  end
end
