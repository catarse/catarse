class AddLocaleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :locale, :text, :null => false, :default => 'pt'
  end

  def self.down
    remove_column :users, :locale
  end
end
