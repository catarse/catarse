class MigrateHowKnowToTrafficSources < ActiveRecord::Migration[4.2]
  def change
    execute "
    UPDATE projects SET traffic_sources = array_append('{}', how_know) WHERE how_know IS NOT NULL;
    "
  end
end
