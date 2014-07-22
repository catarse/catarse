class MigrateHowKnowToTrafficSources < ActiveRecord::Migration
  def change
    execute "
    UPDATE projects SET traffic_sources = array_append('{}', how_know) WHERE how_know IS NOT NULL;
    "
  end
end
