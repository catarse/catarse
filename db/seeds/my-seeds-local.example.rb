## Update this configuration seed and then run
## rake db:seed:my-seeds

puts "Adding OauthProvider settings..."

  puts "  Facebook..."

  ## catarse-local-dev Facebook App
  facebook = OauthProvider.find_or_initialize_by_name 'facebook' 
  facebook.update_attributes(
    key: '556758001037275',
    secret: '5b3a847321b426f9dabd011359a21400',
    path: 'facebook'
  )
  
    
  #OauthProvider.create :name => 'Twitter', :key => 'myconsumerkey', :secret => 'myconsumersecret', :strategy => 'Twitter', :path => 'twitter'
  #OauthProvider.create :name => 'LinkedIn', :key => 'myconsumerkey', :secret => 'myconsumersecret', :strategy => 'LinkedIn', :path => 'linked_in'

###
## Uservoice.com seetings
## at YOURDOMAIN.uservoice.com/admin/settings#/channels
## Sendgrid Heroku Plugin Settings
puts "Creating Configuration entries..."
{
  
  catarse_fee: '0.13',
  company_name: 'Catarse',

  host: 'YOUR_HOST',
  base_domain: 'YOUR_DOMAIN',
  base_url: "YOUR_BASE_URL",

  facebook_url: "http://facebook.com/MY-FACEBOOK-PAGE",
  facebook_app_id: '556758001037275',
  uservoice_subdomain: 'MY-USER-VOICE.uservoice.com',                  
  uservoice_sso_key: 'MY-USER-VOICE-KEY',                         
  uservoice_secret_gadget: 'MY-USER-VOICE-SECRET', 
  sendgrid_user_name: 'MY-HEROKU-SENDGRID-APP@heroku.com',                        
  sendgrid: 'MY-HEROKU-SENDGRID-KEY',                                                 
  mailchimp_url: "YOUR_MAIL_CHIMP_URL",

  blog_url: "YOUR_BLOG_URL",
  twitter_username: "YOUR_TWITTER",
  email_contact: 'EMAIL_ACCOUNT',
  email_payments: 'EMAIL_ACCOUNT',
  email_projects: 'EMAIL_ACCOUNT',
  email_system: 'EMAIL_ACCOUNT',
  email_no_reply: 'EMAIL_ACCOUNT',
  support_forum: 'YOUR_SUPPORT_URL',
  
}.each do |name, value|
   conf = Configuration.find_or_initialize_by_name name
   conf.update_attributes({
     value: value
   })
end

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
