namespace :project do
  desc 'This task will finish the project and send notifications to everyone.'
  task :finish => :environment do
    project = Project.find ENV["PROJECT_ID"]
    print "Finishing project..."
    if project.finish!
      puts "OK!"
    else
      puts "couldn't finish."
    end
  end
end
