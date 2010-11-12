class CreateRewards < ActiveRecord::Migration
  def self.up
    create_table :rewards do |t|
      t.references :project
      t.float :minimum_value
      t.integer :maximum_backers
      t.text :description
      t.timestamps
    end
    # TODO
    #constrain :rewards do |t|
    #  t.project_id :not_blank => true, :reference => {:projects => :id}
    #  t.minimum_value :not_blank, :positive => true
    #  t.maximum_backers :not_blank
    #  #TODO something to check if maximum_backers >= 0
    #  t.description :not_blank
    #end
    add_index :rewards, :project_id
  end

  def self.down
    drop_table :rewards
  end
end

