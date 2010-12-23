# coding: utf-8
require 'sexy_pg_constraints'
class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.text :name, :null => false
      t.timestamps
    end
    constrain :categories do |t|
      t.name :not_blank => true, :unique => true
    end
    add_index :categories, :name
  end
  def self.down
    drop_table :categories
  end
end
