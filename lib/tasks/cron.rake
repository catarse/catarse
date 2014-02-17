desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Project.to_finish.each do |project|
    CampaignFinisherWorker.perform_async(project.id)
  end
end

desc "This tasks should be executed 1x per day"
task notify_project_owner_about_new_confirmed_contributions: :environment do
  Project.with_contributions_confirmed_today.each do |project|
    Notification.notify_once(
      :project_owner_contribution_confirmed,
      project.user,
      {user_id: project.user.id, project_id: project.id, 'notifications.created_at' => Date.today},
      {project: project}
    )
  end
end

desc "Move to deleted state all contributions that are in pending a lot of time"
task :move_pending_contributions_to_trash => [:environment] do
  Contribution.where("state in('pending') and created_at + interval '6 days' < current_timestamp").update_all({state: 'deleted'})
end

desc "Cancel all waiting_confirmation contributions that is passed 4 weekdays"
task :cancel_expired_waiting_confirmation_contributions => :environment do
  Contribution.can_cancel.update_all(state: 'canceled')
end

desc "Send notification about credits 1 month after the project failed"
task send_credits_notification: :environment do
  User.send_credits_notification
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

desc "Migrate project thumbnails to new format"
task :migrate_project_thumbnails => :environment do
  p1 = Project.where('uploaded_image is not null').all
  p2 = Project.where('image_url is not null').all - p1
  p3 = Project.where('video_url is not null').all - p1 - p2

  p1.each do |project|
    begin
      project.uploaded_image.recreate_versions! if project.uploaded_image.file.present?
      puts "Recreating versions: #{project.id} - #{project.name}"
    rescue Exception => e
      puts "Original image not found"
    end
  end

  p2.each do |project|
    begin
      project.uploaded_image = open(project.image_url)
      puts "Downloading thumbnail: #{project.id} - #{project.name}"
      project.save!
    rescue Exception => e
      puts "Couldn't read #{project.image_url} on project #{project.id}, downloading thumbnail from video..."
      project.download_video_thumbnail
      project.save! if project.valid?
    end
  end

  p3.each do |project|
    begin
      project.download_video_thumbnail
      puts "Downloading thumbnail from video: #{project.id} - #{project.name}"
      project.save!
    rescue Exception => e
      puts "Couldn't read: #{project.video_url}"
    end
  end

end
