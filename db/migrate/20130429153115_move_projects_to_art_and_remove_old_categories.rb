# encoding: utf-8

class MoveProjectsToArtAndRemoveOldCategories < ActiveRecord::Migration
  def up
    execute "
      UPDATE projects SET category_id = (SELECT id FROM categories WHERE name_pt = 'Arte') WHERE category_id = (SELECT id FROM categories WHERE name_pt = 'Feito à mão');
      UPDATE projects SET category_id = (SELECT id FROM categories WHERE name_pt = 'Arte') WHERE category_id = (SELECT id FROM categories WHERE name_pt = 'Graffiti');
      DELETE FROM categories WHERE name_pt = 'Feito à mão';
      DELETE FROM categories WHERE name_pt = 'Graffiti';
    "
  end

  def down
  end
end
