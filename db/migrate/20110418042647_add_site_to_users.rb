# coding: utf-8
require 'sexy_pg_constraints'
class AddSiteToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.references :site, :null => false, :default => 1
    end
    constrain :users do |t|
      t.site_id :reference => {:sites => :id}
    end
  end

  def self.down
    remove_column :users, :site_id
  end
end
