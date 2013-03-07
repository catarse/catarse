desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Project.finish_projects!
end

desc "Create first versions for rewards"
task :index_rewards_versions => :environment do
  Reward.all.each do |reward|
    unless reward.versions.count > 0
      puts "update! #{reward.id}"
      reward.update_attributes(reindex_versions: DateTime.now)
    end
  end
end

