class GtmToProject < ActiveRecord::Migration
  def change
    add_column :projects, :tracker_snippet_html, :text
  end
end
