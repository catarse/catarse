class AddAcceptBitcoinToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :accept_bitcoin, :boolean, default: false
  end
end
