# coding: utf-8

puts 'Seeding the database...'

[
  { pt: 'Arte', en: 'Art' },
  { pt: 'Artes plásticas', en: 'Visual Arts' },
  { pt: 'Circo', en: 'Circus' },
  { pt: 'Comunidade', en: 'Community' },
  { pt: 'Humor', en: 'Humor' },
  { pt: 'Quadrinhos', en: 'Comicbooks' },
  { pt: 'Dança', en: 'Dance' },
  { pt: 'Design', en: 'Design' },
  { pt: 'Eventos', en: 'Events' },
  { pt: 'Moda', en: 'Fashion' },
  { pt: 'Gastronomia', en: 'Gastronomy' },
  { pt: 'Cinema e Vídeo', en: 'Film & Video' },
  { pt: 'Jogos', en: 'Games' },
  { pt: 'Jornalismo', en: 'Journalism' },
  { pt: 'Música', en: 'Music' },
  { pt: 'Fotografia', en: 'Photography' },
  { pt: 'Ciência e Tecnologia', en: 'Science & Technology' },
  { pt: 'Teatro', en: 'Theatre' },
  { pt: 'Esporte', en: 'Sport' },
  { pt: 'Web', en: 'Web' },
  { pt: 'Carnaval', en: 'Carnival' },
  { pt: 'Arquitetura e Urbanismo', en: 'Architecture & Urbanism' },
  { pt: 'Literatura', en: 'Literature' },
  { pt: 'Mobilidade e Transporte', en: 'Mobility & Transportation' },
  { pt: 'Meio Ambiente', en: 'Environment' },
  { pt: 'Negócios Sociais', en: 'Social Business' },
  { pt: 'Educação', en: 'Education' },
  { pt: 'Filmes de Ficção', en: 'Fiction Films' },
  { pt: 'Filmes Documentários', en: 'Documentary Films' },
  { pt: 'Filmes Universitários', en: 'Experimental Films' }
].each do |name|
   category = Category.find_or_initialize_by(name_en: name[:en])
   category.update_attributes({
     name_pt: name[:pt]
   })
 end


{
  company_name: 'Fundoo',
  company_logo: 'http://placehold.it/200x100&text=Fundoo.png',
  host: 'fundoo.es',
  base_url: "http://www.fundoo.es",
  email_contact: 'contato@fundoo.es',
  email_payments: 'financeiro@fundoo.es',
  email_projects: 'projetos@fundoo.es',
  email_system: 'system@fundoo.es',
  email_no_reply: 'no-reply@fundoo.es',
  facebook_url: "http://facebook.com/fundoo",
  facebook_app_id:  ENV['FACEBOOK_API_ID'],
  twitter_url: 'http://twitter.com/fundoo',
  twitter_username: "catarse",
  mailchimp_url: "http://catarse.us5.list-manage.com/subscribe/post",
  catarse_fee: '0.00',
  support_forum: 'http://support.fundoo.es/',
  base_domain: 'www.fundoo.es',
  uservoice_secret_gadget: 'change_this',
  uservoice_key: 'uservoice_key',
  faq_url: 'http://support.fundoo.es/',
  feedback_url: 'http://support.fundoo.es',
  terms_url: 'http://support.fundoo.es',
  privacy_url: 'http://support.fundoo.es',
  about_channel_url: 'http://blog.fundoo.es',
  instagram_url: 'http://instagram.com/fundoo',
  blog_url: "http://blog.fundoo.es",
  github_url: 'http://github.com/catarse',
  contato_url: 'http://support.fundoo.es/',
  stripe_api_key: ENV['STRIPE_API_KEY'],
  stripe_secret_key: ENV['STRIPE_SECRET_KEY'],
  stripe_test: 'TRUE',
  stripe_client_id: ENV['STRIPE_CLIENT_ID'],
  mixpanel_token: ENV['MIXPANEL_TOKEN']
}.each do |name, value|
   conf = CatarseSettings.find_or_initialize_by(name: name)
   conf.update_attributes({
     value: value
   })
end


Channel.find_or_create_by!(name: "Channel name") do |c|
  c.permalink = "sample-permalink"
  c.description = "Lorem Ipsum"
end

oauth = OauthProvider.find_or_initialize_by(name: 'facebook') 
oauth.update_attributes({
  key: ENV['FACEBOOK_API_ID'],
  secret: ENV['FACEBOOK_SECRET'],
  path: 'facebook'  
})

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

CatarseSettings.all.each do |conf|
  a = conf.attributes
  puts "  #{a['name']}: #{a['value']}"
end

Rails.cache.clear

puts '---------------------------------------------'
puts 'Done!'
