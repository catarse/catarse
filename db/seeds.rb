# coding: utf-8

[
  'Arte','Artes plásticas','Circo','Comunidade',
  'Feito à mão','Humor','Quadrinhos','Dança',
  'Design','Eventos','Moda','Comida',
  'Cinema & Vídeo','Jogos','Jornalismo',
  'Música','Fotografia','Tecnologia','Teatro','Literatura'
].each do |name|
   Category.find_or_create_by_name name
 end

[
  'confirm_backer','payment_slip','project_success','backer_project_successful',
  'backer_project_unsuccessful','project_received','updates','project_unsuccessful',
  'project_visible','processing_payment','new_draft_project', 'project_rejected'
].each do |name|
  NotificationType.find_or_create_by_name name
end

{
  host: 'catarse.me',
  base_url: "http://catarse.me",
  blog_url: "http://blog.catarse.me",
  email_contact: 'contato@catarse.me',
  email_payments: 'financeiro@catarse.me',
  email_projects: 'projetos@catarse.me',
  email_system: 'system@catarse.me',
  email_no_reply: 'no-reply@catarse.me',
  facebook_url: "http://facebook.com/catarse.me",
  facebook_app_id: '173747042661491',
  twitter_username: "Catarse_",
  mailchimp_url: "http://catarse.us5.list-manage.com/subscribe/post?u=ebfcd0d16dbb0001a0bea3639&amp;id=149c39709e",
}.each do |name, value|
  Configuration.find_or_create_by_name_and_value name, value
end
