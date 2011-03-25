namespace :project do
  desc 'This task will finish the project and send notifications to everyone.'
  task :finish => :environment do
    project = Project.find ENV["PROJECT_ID"]
    print "Finalizando projeto..."
    if project.finish!
      puts "OK!"
    else
      puts "não foi possível."
    end
  end
end
