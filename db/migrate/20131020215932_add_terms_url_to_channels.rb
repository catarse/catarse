class AddTermsUrlToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :terms_url, :string
  end
end
