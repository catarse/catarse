# encoding: utf-8

class MoveProjectsToArtAndRemoveOldCategories < ActiveRecord::Migration
  def up
    execute "
      UPDATE projects SET category_id = (SELECT id FROM categories WHERE name_en = 'Arte') WHERE category_id = (SELECT id FROM categories WHERE name_en = 'Feito à mão');
      UPDATE projects SET category_id = (SELECT id FROM categories WHERE name_en = 'Arte') WHERE category_id = (SELECT id FROM categories WHERE name_en = 'Graffiti');
      DELETE FROM categories WHERE name_en = 'Feito à mão';
      DELETE FROM categories WHERE name_en = 'Graffiti';
    "
  end

  def down
  end
end
