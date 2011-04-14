# coding: utf-8
require 'sexy_pg_constraints'
class AddSiteToNotifications < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.references :site, :null => false, :default => 1
    end
    constrain :notifications do |t|
      t.site_id :reference => {:sites => :id}
    end
  end

  def self.down
    remove_column :notifications, :site_id
  end
end
