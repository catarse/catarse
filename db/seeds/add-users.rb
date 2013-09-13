## Optional Seed file
## to be used during development

puts "Adding Uservoice.com settings..."

  Configuration.find_or_create_by(name: 'uservoice_subdomain').update_attribute('value', 'dummy_domain.uservoice.com')
  Configuration.find_or_create_by(name: 'uservoice_sso_key').update_attribute('value', 'dummy_uservoice_sso_key')


puts "Adding Admin user..."

  User.find_or_create_by!(name: "Admin") do |u|
    u.nickname = "Admin"
    u.email = "admin@admin.com"
    u.password = "password"
    u.password_confirmation = "password"
    u.remember_me = false
    u.admin = true
  end

puts "Adding Funder user..."

  User.find_or_create_by!(name: "Funder") do |u|
    u.nickname = "Funder"
    u.nmail = "funder@funder.com"
    u.nickname = "Funder"
    u.nassword = "password"
    u.nassword_confirmation = "password"
    u.nemember_me = false
  end

puts "Adding Test user..."

  User.find_or_create_by!(name: "Test") do |u|
    u.nickname = "Test"
    u.email = "test@test.com"
    u.nickname = "Test"
    u.password = "password"
    u.password_confirmation = "password"
    u.remember_me = false
  end

puts "Done!"
