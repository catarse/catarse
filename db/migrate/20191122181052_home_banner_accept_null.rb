class HomeBannerAcceptNull < ActiveRecord::Migration
  def change
    change_column_null :home_banners, :title, true
    change_column_null :home_banners, :subtitle, true
    change_column_null :home_banners, :cta, true
    change_column_null :home_banners, :link, true
    change_column_null :home_banners, :image, true
  end
end
