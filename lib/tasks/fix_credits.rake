desc "Check for inconsistencies in users credits, and fix incorrect ones"
task :fix_credit => :environment do
  # User.includes(:backs).each do |user|
  #   user.
  # end

  total = 0
  negative = []
  negative_sum = 0
  User.all.each do |user|
    uc = user.credits
    ucc = user.calculate_credits
    if uc != ucc
      puts "Verificando #{user.id}: #{user.name}"
      puts "#{uc} != #{ucc}"
      total += 1
      if ucc < 0
        negative << user.id
        negative_sum += ucc
        user.update_attribute :credits, 0
      else
        user.update_attribute :credits, ucc
      end
    end
  end
  puts "total fixed: #{total}"
  puts "negative: #{negative}"
  puts "loss: #{negative_sum}"
end