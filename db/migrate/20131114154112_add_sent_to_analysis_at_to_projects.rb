class AddSentToAnalysisAtToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :sent_to_analysis_at, :timestamp
  end
end
