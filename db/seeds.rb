# coding: utf-8

[
  { pt: 'Arte', en: 'Art' },
  { pt: 'Artes plásticas', en: 'Visual Arts' },
  { pt: 'Circo', en: 'Circus' },
  { pt: 'Comunidade', en: 'Community' },
  { pt: 'Feito à mão', en: 'Handmade' },
  { pt: 'Humor', en: 'Humor' },
  { pt: 'Quadrinhos', en: 'Comicbooks' },
  { pt: 'Dança', en: 'Dance' },
  { pt: 'Design', en: 'Design' },
  { pt: 'Eventos', en: 'Events' },
  { pt: 'Moda', en: 'Fashion' },
  { pt: 'Comida', en: 'Food' },
  { pt: 'Cinema & Vídeo', en: 'Film & Video' },
  { pt: 'Jogos', en: 'Games' },
  { pt: 'Jornalismo', en: 'Journalism' },
  { pt: 'Música', en: 'Music' },
  { pt: 'Fotografia', en: 'Photography' },
  { pt: 'Tecnologia', en: 'Technology' },
  { pt: 'Teatro', en: 'Theatre' },
  { pt: 'Esporte', en: 'Sport' },
  { pt: 'Graffiti', en: 'Graffiti' },
  { pt: 'Web', en: 'Web' },
  { pt: 'Carnaval', en: 'Carnival' },
  { pt: 'Arquitetura & Urbanismo', en: 'Architecture & Urbanism' },
  { pt: 'Literatura', en: 'Literature' }
].each do |name|
   category = Category.find_or_initialize_by_name_pt name[:pt]
   category.update_attributes({
     name_en: name[:en]
   })
 end

[
  'confirm_backer','payment_slip','project_success','backer_project_successful',
  'backer_project_unsuccessful','project_received','updates','project_unsuccessful',
  'project_visible','processing_payment','new_draft_project', 'project_rejected', 'pending_backer_project_unsuccessful'
].each do |name|
  NotificationType.find_or_create_by_name name
end

{
  company_name: 'Catarse',
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
  catarse_fee: '0.13',
  support_forum: 'http://suporte.catarse.me/'
}.each do |name, value|
  Configuration.find_or_create_by_name name, value: value
end
