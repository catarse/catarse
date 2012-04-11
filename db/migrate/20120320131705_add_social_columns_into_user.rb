class AddSocialColumnsIntoUser < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter, :string
    add_column :users, :facebook_link, :string
    add_column :users, :other_link, :string
  end

  def self.down
    remove_column :users, :twitter
    remove_column :users, :facebook_link
    remove_column :users, :other_link
  end
end
