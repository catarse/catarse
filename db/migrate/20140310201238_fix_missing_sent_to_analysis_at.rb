class FixMissingSentToAnalysisAt < ActiveRecord::Migration
  def up
    execute "
    UPDATE projects SET sent_to_analysis_at = created_at WHERE sent_to_analysis_at IS NULL AND state <> 'draft';
    "
  end

  def down
  end
end
