# coding: utf-8
require 'sexy_pg_constraints'
class AddSiteToProjects < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.references :site, :null => false, :default => 1
    end
    constrain :projects do |t|
      t.site_id :reference => {:sites => :id}
    end
  end

  def self.down
    remove_column :projects, :site_id
  end
end
