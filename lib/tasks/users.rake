namespace :user do
  desc 'This task will sync the users with newsletter = true with Mailee.'
  task :sync_with_mailee => :environment do
    print "Sincronizando contatos..."
    User.where(:newsletter => true).each do |user|
      user.update_attribute :newsletter, true
    end
    puts "OK!"
  end
end
