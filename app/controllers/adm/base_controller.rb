class Adm::BaseController < ApplicationController
  inherit_resources
  before_filter do
    authorize! :manage, resource_class  
  end

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

  def current_ability
    controller_name_segments = params[:controller].split('/')
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join('/').camelize
    @current_ability ||= Ability.new(current_user, { namespace: controller_namespace })
  end


end
