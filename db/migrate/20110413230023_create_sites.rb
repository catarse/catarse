# coding: utf-8
require 'sexy_pg_constraints'
class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.text :name, :null => false
      t.text :title, :null => false
      t.text :path, :null => false
      t.text :host, :null => false
      t.text :gender, :null => false
      t.text :email, :null => false
      t.text :twitter, :null => false
      t.text :facebook, :null => false
      t.text :blog, :null => false
      t.timestamps
    end
    constrain :sites do |t|
      t.name :not_blank => true, :unique => true
      t.title :not_blank => true
      t.path :not_blank => true, :unique => true
      t.host :not_blank => true, :unique => true
      t.gender :not_blank => true
      t.email :not_blank => true
      t.twitter :not_blank => true
      t.facebook :not_blank => true
      t.blog :not_blank => true
    end
    execute "INSERT INTO sites (name, title, path, host, gender, email, twitter, facebook, blog) VALUES
    ('Catarse', 'A primeira plataforma de financiamento colaborativo de projetos criativos do Brasil', 'catarse', 'catarse.me', 'male', 'contato@catarse.me', 'Catarse_', 'http://www.facebook.com/Catarse.me', 'http://blog.catarse.me'),
    ('Multidão', 'Produção Cultural Colaborativa', 'multidao', 'multidao.localhost', 'female', 'contato@multidao.art.br', 'multidao_art', 'http://www.facebook.com/pages/Multidaoart/139326962792941', 'http://blog.multidao.art.br')
    "
  end

  def self.down
    drop_table :sites
  end
end
