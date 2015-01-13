class AddZeroCreditsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :zero_credits, :boolean, default: false
  end
end
