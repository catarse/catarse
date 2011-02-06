class AddStrategyAndPathToOauthProviders < ActiveRecord::Migration
  def self.up
    add_column :oauth_providers, :strategy, :text
    add_column :oauth_providers, :path, :text
  end

  def self.down
    remove_column :oauth_providers, :strategy
    remove_column :oauth_providers, :path
  end
end
