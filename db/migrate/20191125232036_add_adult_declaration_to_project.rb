class AddAdultDeclarationToProject < ActiveRecord::Migration
  def up
    add_column :projects, :content_rating, :integer
  end

  def down
    remove_column :projects, :content_rating
  end
end
