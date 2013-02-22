# This migration comes from catarse_stripe (originally 20130219201753)
class AddStripeUseridAndStripeAccessTokenToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :stripe_userid, :string
    add_column :projects, :stripe_access_token, :string
  end
end
