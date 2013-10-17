class AddHowItWorksHtmlToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :how_it_works_html, :text
  end
end
