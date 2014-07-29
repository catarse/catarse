class AddGaCodeIntoChannels < ActiveRecord::Migration
  def change
    add_column :channels, :ga_code, :text
  end
end
