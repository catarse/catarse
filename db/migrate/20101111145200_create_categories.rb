class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
    # TODO
    #constrain :categories do |t|
    #  t.name :not_blank => true, :unique => true
    #end
    add_index :categories, :name
    # TODO find out why doesn't it work with special characters
    execute "INSERT INTO categories (name) VALUES ('Arte')"
    execute "INSERT INTO categories (name) VALUES ('Comunidade')"
    execute "INSERT INTO categories (name) VALUES ('Feito a mao')"
    execute "INSERT INTO categories (name) VALUES ('Humor')"
    execute "INSERT INTO categories (name) VALUES ('Quadrinhos')"
    execute "INSERT INTO categories (name) VALUES ('Danca')"
    execute "INSERT INTO categories (name) VALUES ('Design')"
    execute "INSERT INTO categories (name) VALUES ('Eventos')"
    execute "INSERT INTO categories (name) VALUES ('Moda')"
    execute "INSERT INTO categories (name) VALUES ('Comida')"
    execute "INSERT INTO categories (name) VALUES ('Cinema & Video')"
    execute "INSERT INTO categories (name) VALUES ('Jogos')"
    execute "INSERT INTO categories (name) VALUES ('Jornalismo')"
    execute "INSERT INTO categories (name) VALUES ('Musica')"
    execute "INSERT INTO categories (name) VALUES ('Fotografia')"
    execute "INSERT INTO categories (name) VALUES ('Tecnologia')"
    execute "INSERT INTO categories (name) VALUES ('Teatro')"
    execute "INSERT INTO categories (name) VALUES ('Literatura')"
  end

  def self.down
    drop_table :categories
  end
end

