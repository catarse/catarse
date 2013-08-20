####
# Task to manage the application users
##
namespace :users do

###
# Syncs users with newsletter
# usage: rake users:sync_with_mailee
##
  desc 'This task will sync the users with newsletter = true with Mailee.'
  task :sync_with_mailee => :environment do
    print "Synchronizing contacts..."
    User.where(:newsletter => true).each do |user|
      user.update_attribute :newsletter, true
    end
    puts "OK!"
  end

  ###
  # Shows all entries in the configuration table
  # usage: rake users:show
  ##
  desc "Shows all entries in the configuration table"
  task :show => :environment do

    puts
    puts '============================================='
    puts ' Application Users'
    puts '---------------------------------------------'

    User.all.each do |conf|
      a = conf.attributes
      print "\nname: #{a['name']}"
      print "\n   nickname: #{a['nickname']}"
      print "\n   email: #{a['email']}"
      print "\n   admin: #{a['admin']}"
      puts
    end

    puts '---------------------------------------------'
    puts 'Done!'
  end

  ###
  # Sets user as administrator
  # usage: rake users:admin[email]
  ##
  desc "Sets user as administrator"
  task :admin, [:email] => :environment do |t, args|
    puts
    puts "Setting #{args[:email]} as administrator..."
    u = User.find_by_email(args[:email])
    unless u
      puts "ERROR: User doesn't exist!"
    next
    end

    u.update_attribute :admin, true
    puts  "#{u.name}: #{u.email} is now an administrator!"
    puts 'Done!'
    puts
  end

  ###
  # Sets first user as administrator
  # usage: rake users:adminfirst
  ##
  desc "Sets first user as administrator"
  task :adminfirst => :environment do
    puts
    unless User.count > 0
      puts "ERROR: User doesn't exist!"
    next
    end

    u = User.first
    u.update_attribute :admin, true
    puts  "#{u.name}: #{u.email} is now an administrator!"
    puts 'Done!'
    puts
  end
end
