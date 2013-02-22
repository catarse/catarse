# This migration comes from catarse_stripe (originally 20130217194840)
class AddStripeKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_key, :string
  end
end
