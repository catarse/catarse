class Create8HomeBannersEntry < ActiveRecord::Migration
  def up
    [0, 1, 2, 3, 4, 5, 6, 7].each { |item|
      HomeBanner.create(title: '', subtitle: '', link: '', cta: '', image: '')
    }
  end

  def down
    HomeBanner.delete_all
  end
end
