class CreateStaticContents < ActiveRecord::Migration
  def self.up
    unless ActiveRecord::Base.connection.tables.include?("static_contents")
      create_table :static_contents do |t|
        t.string :title
        t.text :body
        t.text :body_html

        t.timestamps
      end
    end
  end

  def self.down
    drop_table :static_contents
  end
end
