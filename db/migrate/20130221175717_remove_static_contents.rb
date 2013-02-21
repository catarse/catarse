class RemoveStaticContents < ActiveRecord::Migration
  def up
    drop_table :static_contents
  end

  def down
    create_table :static_contents do
      t.text :title
      t.text :body
      t.text :body_html
    end
  end
end
