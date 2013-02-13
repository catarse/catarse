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
      instance_variable = instance_variable_get("@#{controller_name.singularize}")
      if instance_variable.errors.empty?
        format.json { respond_with_bip(instance_variable) }
      else
        format.html { render action: "edit" }
        format.json { respond_with_bip(instance_variable) }
      end
    end
  end
end
