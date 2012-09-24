# coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
ActiveRecord::Base.connection.execute "INSERT INTO categories (name) VALUES ('Arte'),
 ('Artes plásticas'),
 ('Circo'),
 ('Comunidade'),
 ('Feito à mão'),
 ('Humor'),
 ('Quadrinhos'),
 ('Dança'),
 ('Design'),
 ('Eventos'),
 ('Moda'),
 ('Comida'),
 ('Cinema & Vídeo'),
 ('Jogos'),
 ('Jornalismo'),
 ('Música'),
 ('Fotografia'),
 ('Tecnologia'),
 ('Teatro'),
 ('Literatura');"

ActiveRecord::Base.connection.execute "INSERT INTO notification_types (name) VALUES ('confirm_backer'), ('payment_slip'), ('project_success');"
