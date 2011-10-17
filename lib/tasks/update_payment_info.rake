namespace :payment do
  desc 'This task will sync the payment details with moip'
  task :sync_with_moipt => :environment do
    print "Synchronizing payments..."
    Backer.where("payment_token is not null and confirmed is false").each do |b|
      p "#{b.key} ---> updating"
      b.build_payment_detail.update_from_service
      p "updated backer #{b.key}"
    end
    puts "OK!"
  end
end
