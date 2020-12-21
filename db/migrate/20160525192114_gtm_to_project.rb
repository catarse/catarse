class GtmToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :tracker_snippet_html, :text
  end
end
