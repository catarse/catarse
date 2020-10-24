class AddSentToDraftAtToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :sent_to_draft_at, :timestamp
  end
end
