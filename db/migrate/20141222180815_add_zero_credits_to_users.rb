class AddZeroCreditsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :zero_credits, :boolean, default: false
  end
end
