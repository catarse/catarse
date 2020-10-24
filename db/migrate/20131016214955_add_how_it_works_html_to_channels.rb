class AddHowItWorksHtmlToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :how_it_works_html, :text
  end
end
