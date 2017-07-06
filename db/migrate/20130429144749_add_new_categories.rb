# encoding: utf-8

class AddNewCategories < ActiveRecord::Migration
  def up
    execute "
    INSERT INTO categories (name_pt, name_en, created_at, updated_at) VALUES ('Mobilidade e Transporte', 'Mobility & Transportation', now(), now());
    INSERT INTO categories (name_pt, name_en, created_at, updated_at) VALUES ('Meio Ambiente', 'Environment', now(), now());
    INSERT INTO categories (name_pt, name_en, created_at, updated_at) VALUES ('Negócios Sociais', 'Social Business', now(), now());
    INSERT INTO categories (name_pt, name_en, created_at, updated_at) VALUES ('Educação', 'Education', now(), now());
    INSERT INTO categories (name_pt, name_en, created_at, updated_at) VALUES ('Filmes de Ficção', 'Fiction Films', now(), now());
    INSERT INTO categories (name_pt, name_en, created_at, updated_at) VALUES ('Filmes Documentários', 'Documentary Films', now(), now());
    INSERT INTO categories (name_pt, name_en, created_at, updated_at) VALUES ('Filmes Universitários', 'Experimental Films', now(), now());
    "
  end

  def down
    execute "
    DELETE FROM categories WHERE name_pt = 'Mobilidade e Transporte';
    DELETE FROM categories WHERE name_pt = 'Meio Ambiente';
    DELETE FROM categories WHERE name_pt = 'Negócios Sociais';
    DELETE FROM categories WHERE name_pt = 'Educação';
    DELETE FROM categories WHERE name_pt = 'Filmes de Ficção';
    DELETE FROM categories WHERE name_pt = 'Filmes Documentários';
    DELETE FROM categories WHERE name_pt = 'Filmes Universitários';
    "
  end
end
