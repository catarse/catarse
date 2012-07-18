namespace :payment do
  desc 'This task will sync the payment details with paypal'
  task :sync_with_paypal => :environment do
    print "Synchronizing payments..."
    Backer.where("payment_method = 'PayPal' AND confirmed is true").each do |b|
      p "#{b.key} ---> updating"
      b.build_payment_detail.update_from_service
      p "updated backer #{b.key} with service fee #{b.payment_detail.service_tax_amount.to_f}"
    end
    puts "OK!"
  end

  desc 'This task will sync the payment details with moip'
  task :sync_with_moip => :environment do
    print "Synchronizing payments..."
    Backer.where("payment_token is not null and confirmed is false").each do |b|
      p "#{b.key} ---> updating"
      b.build_payment_detail.update_from_service
      p "updated backer #{b.key}"
    end
    puts "OK!"
  end

  desc 'look with moip what the backer already have refunded'
  task :mark_refunded => :environment do
    Backer.where(:payment_method => 'MoIP').where('payment_token is not null').each do |backer|
      response = MoIP::Client.query(backer.payment_token)
      begin
        if response['Pagamento'].present?
          if response["Pagamento"]["Status"]["Tipo"].to_i == 7 || response["Pagamento"]["Status"]["Tipo"].to_i == 9
            puts "preparando para extornar o apoio ---> #{backer.inspect}"
            backer.update_attribute :refunded, true
            backer.update_attribute :requested_refund, true
            backer.user.update_credits
          end
        end
      rescue
        puts "error on process response for --> #{backer.inspect}"
      end
    end
  end
end
