# coding: utf-8
require 'sexy_pg_constraints'
class AddSiteToBackers < ActiveRecord::Migration
  def self.up
    change_table :backers do |t|
      t.references :site, :null => false, :default => 1
    end
    constrain :backers do |t|
      t.site_id :reference => {:sites => :id}
    end
  end

  def self.down
    remove_column :backers, :site_id
  end
end
