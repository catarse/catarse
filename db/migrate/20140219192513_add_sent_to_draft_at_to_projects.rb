class AddSentToDraftAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :sent_to_draft_at, :timestamp
  end
end
