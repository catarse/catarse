## Optional Seed file 
## to be used during development

puts "Adding Uservoice.com settings..."

  Configuration.find_or_create_by_name('uservoice_subdomain').update_attribute('value', 'dummy_domain.uservoice.com')  
  Configuration.find_or_create_by_name('uservoice_sso_key').update_attribute('value', 'dummy_uservoice_sso_key')


puts "Adding Admin user..."

  User.find_or_create_by_name!(
    name: "Admin",
    nickname: "Admin",
    email: "admin@admin.com",
    nickname: "Admin",
    password: "password",
    password_confirmation: "password",
    remember_me: false,
    admin: true
  )
  
puts "Adding Funder user..."

  User.find_or_create_by_name!(
    name: "Funder",
    nickname: "Funder",
    email: "funder@funder.com",
    nickname: "Funder",
    password: "password",
    password_confirmation: "password",
    remember_me: false
  )

puts "Adding Test user..."

  User.find_or_create_by_name!(
    name: "Test",
    nickname: "Test",
    email: "test@test.com",
    nickname: "Test",
    password: "password",
    password_confirmation: "password",
    remember_me: false
  )

puts "Done!"
