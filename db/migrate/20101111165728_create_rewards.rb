require 'sexy_pg_constraints'
class CreateRewards < ActiveRecord::Migration
  def self.up
    create_table :rewards do |t|
      t.references :project, :null => false
      t.float :minimum_value, :null => false
      t.integer :maximum_backers, :null => true
      t.string :description, :null => false
      t.timestamps
    end
    constrain :rewards do |t|
      t.project_id :reference => {:projects => :id}
      t.minimum_value :positive => true
      t.maximum_backers :positive => true
      t.description :not_blank => true, :length_within => 1..140
    end
    add_index :rewards, :project_id
  end
  def self.down
    drop_table :rewards
  end
end
