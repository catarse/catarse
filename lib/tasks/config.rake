####
# Task to manage the application configuration table 
##
namespace :config do
  ###
  # Shows all entries in the configuration table
  # usage: rake config:show
  ##
  desc "Shows all entries in the configuration table\n usage: rake config:show"
  task :show => :environment do
    
    puts 
    puts '============================================='
    puts ' Showing all Authentication Providers'
    puts '---------------------------------------------'
    
    OauthProvider.all.each do |conf|
      a = conf.attributes
      puts "  name #{a['name']}"
      puts "     key: #{a['key']}"
      puts "     secret: #{a['secret']}"
      puts "     path: #{a['path']}"
      puts 
    end
  
    
    puts 
    puts '============================================='
    puts ' Showing all entries in Configuration Table...'
    puts '---------------------------------------------'
    
    Configuration.all.each do |conf|
      a = conf.attributes
      puts "  #{a['name']}: #{a['value']}"
    end
    
    puts '---------------------------------------------'
    puts 'Done!'
  end
  
  ###
  # Adds an entry to the configuration table
  # usage: rake config:put[config_name,config_value]
  ##
  desc "Adds an entry to the configuration table\n usage: rake config:put"
  task :put, [:name, :value] => :environment do |t, args|
    puts
    puts "Adding #{args[:name]}=#{args[:value]} to configuration table..."
    conf = Configuration.find_or_initialize_by_name args[:name] 
    conf.update_attributes(
      value: args[:value],
    )
    puts 'Done!'
    puts
  end
end
