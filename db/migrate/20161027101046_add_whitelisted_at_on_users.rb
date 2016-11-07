class AddWhitelistedAtOnUsers < ActiveRecord::Migration
  def change
    add_column :users, :whitelisted_at, :datetime
  end
end
