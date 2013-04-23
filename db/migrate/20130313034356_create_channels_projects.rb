class CreateChannelsProjects < ActiveRecord::Migration
  def change
    create_table :channels_projects do |t|
      t.integer :channel_id, index: { with: :project_id, unique: true }
      t.integer :project_id, index: true
    end
  end
end
