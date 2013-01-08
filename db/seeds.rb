# coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

['Arte','Artes plásticas','Circo','Comunidade',
'Feito à mão','Humor','Quadrinhos','Dança',
'Design','Eventos','Moda','Comida',
'Cinema & Vídeo','Jogos','Jornalismo',
'Música','Fotografia','Tecnologia','Teatro','Literatura'].each do |name|
   Category.find_or_create_by_name name
 end

['confirm_backer','payment_slip','project_success','backer_project_successful',
'backer_project_unsuccessful','project_received','updates','project_unsuccessful',
'project_visible','processing_payment','new_draft_project'].each do |name|
  NotificationType.find_or_create_by_name name
end
