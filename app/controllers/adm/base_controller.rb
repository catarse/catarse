class Adm::BaseController < ApplicationController
  inherit_resources
  before_filter :require_admin
  @@menu_items = {}
  cattr_accessor :menu_items

  def self.menu menu=nil
    if menu
      self.menu_items.merge! menu
    else
      self.menu_items
    end
  end

  def update
    update! do |format|
      if resource.errors.empty?
        format.json { respond_with_bip(resource) }
      else
        format.html { render action: "edit" }
        format.json { respond_with_bip(resource) }
      end
    end
  end
end
