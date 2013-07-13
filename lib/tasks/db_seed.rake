####
#This will allow you to do rake db:seed:x 
#where “x” is a file in the db/seeds directory
##
namespace :db do
  namespace :seed do
    Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each do |seed_file|
      task_name = File.basename(seed_file, '.rb').intern    
      desc "Load the seed data from db/seeds/#{task_name}.rb"
      task task_name => :environment do
        load(seed_file) if File.exist?(seed_file)
      end
    end
  end
end