class Admin::BaseController < ApplicationController
  inherit_resources
  before_filter do
    authorize! :access, :admin
  end

  def update
    update! do |format|
      if resource.errors.empty?
        format.json { respond_with_bip(resource) }
      else
        format.html { render :edit }
        format.json { respond_with_bip(resource) }
      end
    end
  end
end
