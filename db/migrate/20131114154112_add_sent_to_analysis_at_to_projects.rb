class AddSentToAnalysisAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :sent_to_analysis_at, :timestamp
  end
end
