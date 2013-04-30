# encoding: utf-8
class RenameCategories < ActiveRecord::Migration
  def up
    execute "
    UPDATE categories SET name_pt = 'Gastronomia', name_en = 'Gastronomy' WHERE name_pt = 'Comida';
    UPDATE categories SET name_pt = 'Ciência e Tecnologia', name_en = 'Science & Technology' WHERE name_pt = 'Tecnologia';
    "
  end

  def down
  end
end
