class AddCardBrandToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :card_brand, :text
  end
end
