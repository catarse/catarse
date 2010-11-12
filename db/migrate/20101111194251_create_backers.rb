class CreateBackers < ActiveRecord::Migration
  def self.up
    create_table :backers do |t|
      t.references :project
      t.references :user
      t.float :value
      t.boolean :confirmed, :default => false
      t.timestamp :confirmed_at
      t.timestamps
    end
    # TODO
    #constrain :backers do |t|
    #  t.project_id :not_blank => true, :reference => {:projects => :id}
    #  t.user_id :not_blank => true, :reference => {:users => :id}
    #  t.value :not_blank, :positive => true
    #end
    add_index :backers, :project_id
    add_index :backers, :user_id
    add_index :backers, :confirmed
  end

  def self.down
    drop_table :backers
  end
end

