class RemoveStaticContents < ActiveRecord::Migration[4.2]
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
