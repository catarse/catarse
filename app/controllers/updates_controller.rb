class UpdatesController < ApplicationController
  inherit_resources

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
    return unless can? :manage, @update
    create! do |format|
      format.html{ return redirect_to project_updates_path(parent) }
    end
  end

  def destroy
    destroy! do |format|
      return index
    end
  end
end
