class AddTermsUrlToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :terms_url, :string
  end
end
