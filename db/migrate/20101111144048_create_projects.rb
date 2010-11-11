class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.references :user
      t.references :category
      t.float :goal
      t.float :pledged
      t.datetime :deadline
      t.text :about
      t.boolean :visible, :default => false
      t.boolean :recommended, :default => false
      t.timestamps
    end
    # TODO
    #constrain :projects do |t|
    #  t.name :not_blank => true
    #  t.user_id :not_blank => true, :reference => {:users => :id}
    #  t.category_id :not_blank => true, :reference => {:categories => :id}
    #end
    add_index :projects, :user_id
    add_index :projects, :category_id
    add_index :projects, :name
  end

  def self.down
    drop_table :projects
  end
end

