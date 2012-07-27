class Adm::BaseController < ApplicationController
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
end
