# This migration comes from catarse_stripe (originally 20130218164300)
class AddStripeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_userid, :string
  end
end
