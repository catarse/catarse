class CreateHomeBanners < ActiveRecord::Migration
  def change
    create_table :home_banners do |t|
      t.string :title
      t.string :subtitle
      t.string :link
      t.string :cta
      t.string :image

      t.timestamps null: false
    end
  end
end
