class AddAuthGatewayAndPortToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :auth_gateway, :boolean, :null => false, :default => false
    add_column :sites, :port, :text
    execute "UPDATE sites SET auth_gateway = true WHERE path = 'catarse'"
  end

  def self.down
    remove_column :sites, :auth_gateway
    remove_column :sites, :port
  end
end
