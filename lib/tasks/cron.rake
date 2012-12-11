desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Project.finish_projects!
end
