# This migration comes from catarse_stripe (originally 20130220030158)
class AddStripeKeyToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :stripe_key, :string
  end
end
