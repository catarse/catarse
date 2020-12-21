class AddWhitelistedAtOnUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :whitelisted_at, :datetime
  end
end
