class AddShippingOptionsToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :shipping_options, :text
  end
end
