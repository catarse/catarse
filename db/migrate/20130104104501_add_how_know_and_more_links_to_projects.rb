class AddHowKnowAndMoreLinksToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :how_know, :text
    add_column :projects, :more_links, :text
  end
end
