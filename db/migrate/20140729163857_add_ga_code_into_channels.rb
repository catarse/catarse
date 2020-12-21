class AddGaCodeIntoChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :ga_code, :text
  end
end
