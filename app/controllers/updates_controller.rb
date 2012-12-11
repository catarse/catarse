class UpdatesController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  actions :index, :create, :destroy
  respond_to :html, :only => [ :index, :create, :destroy ]
  belongs_to :project

  def index
    index! do |format|
      format.html{ return render :index, :layout => false }
    end
  end

  def create
    @update = parent.updates.new(params[:update])
    @update.user = current_user
    create! do |format|
      format.html{ return redirect_to project_path(parent, :anchor => 'updates') }
    end
  end

  def destroy
    destroy! do |format|
      return index
    end
  end
end
