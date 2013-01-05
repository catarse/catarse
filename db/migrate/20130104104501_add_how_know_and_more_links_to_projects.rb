class AddHowKnowAndMoreLinksToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :how_know, :text
    add_column :projects, :more_links, :text
  end
end
