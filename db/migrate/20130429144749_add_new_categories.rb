# encoding: utf-8

class AddNewCategories < ActiveRecord::Migration
  def up
    execute "
    INSERT INTO categories (name_en, name_en, created_at, updated_at) VALUES ('Mobilidade e Transporte', 'Mobility & Transportation', now(), now());
    INSERT INTO categories (name_en, name_en, created_at, updated_at) VALUES ('Meio Ambiente', 'Environment', now(), now());
    INSERT INTO categories (name_en, name_en, created_at, updated_at) VALUES ('Negócios Sociais', 'Social Business', now(), now());
    INSERT INTO categories (name_en, name_en, created_at, updated_at) VALUES ('Educação', 'Education', now(), now());
    INSERT INTO categories (name_en, name_en, created_at, updated_at) VALUES ('Filmes de Ficção', 'Fiction Films', now(), now());
    INSERT INTO categories (name_en, name_en, created_at, updated_at) VALUES ('Filmes Documentários', 'Documentary Films', now(), now());
    INSERT INTO categories (name_en, name_en, created_at, updated_at) VALUES ('Filmes Universitários', 'Experimental Films', now(), now());
    "
  end

  def down
    execute "
    DELETE FROM categories WHERE name_en = 'Mobilidade e Transporte';
    DELETE FROM categories WHERE name_en = 'Meio Ambiente';
    DELETE FROM categories WHERE name_en = 'Negócios Sociais';
    DELETE FROM categories WHERE name_en = 'Educação';
    DELETE FROM categories WHERE name_en = 'Filmes de Ficção';
    DELETE FROM categories WHERE name_en = 'Filmes Documentários';
    DELETE FROM categories WHERE name_en = 'Filmes Universitários';
    "
  end
end
