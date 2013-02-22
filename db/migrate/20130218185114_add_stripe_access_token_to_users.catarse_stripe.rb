# This migration comes from catarse_stripe (originally 20130218184756)
class AddStripeAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_access_token, :string
  end
end
