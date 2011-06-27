desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Project.where(:can_finish => true, :finished => false).each do |project|
    puts "Finishing project ##{project.id}..."
    if project.finish!
      puts "...OK!"
    else
      puts "...couldn't finish."
    end
  end
end
