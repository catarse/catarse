class AddCardBrandToContributions < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :card_brand, :text
  end
end
