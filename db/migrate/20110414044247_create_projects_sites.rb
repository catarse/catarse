# coding: utf-8
require 'sexy_pg_constraints'
class CreateProjectsSites < ActiveRecord::Migration
  def self.up
    create_table :projects_sites do |t|
      t.references :project, :null => false
      t.references :site, :null => false
      t.boolean :visible, :null => false, :default => false
      t.boolean :rejected, :null => false, :default => false
      t.boolean :recommended, :null => false, :default => false
      t.boolean :home_page, :null => false, :default => false
      t.integer :order
      t.timestamps
    end
    constrain :projects_sites do |t|
      t.project_id :reference => {:projects => :id}
      t.site_id :reference => {:sites => :id}
      t[:project_id, :site_id].all :unique => true
    end
  end

  def self.down
    drop_table :projects_sites
  end
end
