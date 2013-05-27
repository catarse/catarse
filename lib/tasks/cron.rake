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

desc "Update video_embed_url column"
task :fill_embed_url => :environment do
  Project.where('video_url is not null and video_embed_url is null').each do |project|
    project.update_video_embed_url
    project.save
  end
end

