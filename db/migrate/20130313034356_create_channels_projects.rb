class CreateChannelsProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :channels_projects do |t|
      t.integer :channel_id
      t.integer :project_id, index: true
    end

    add_index :channels_projects, %i[channel_id project_id], unique: true
  end
end
