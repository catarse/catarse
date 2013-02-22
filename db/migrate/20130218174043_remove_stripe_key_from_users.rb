class RemoveStripeKeyFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :stripe_key
  end
end
