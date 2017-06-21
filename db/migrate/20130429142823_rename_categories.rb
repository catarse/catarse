# encoding: utf-8
class RenameCategories < ActiveRecord::Migration
  def up
    execute "
    UPDATE categories SET name_en = 'Gastronomia', name_en = 'Gastronomy' WHERE name_en = 'Comida';
    UPDATE categories SET name_en = 'Ciência e Tecnologia', name_en = 'Science & Technology' WHERE name_en = 'Tecnologia';
    "
  end

  def down
  end
end
