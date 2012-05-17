class UpdatesController < ApplicationController
  inherit_resources

  actions :index, :create, :destroy
  respond_to :html, :only => [ :index, :create, :destroy ]
  belongs_to :project

  before_filter :set_user_id, :only => [ :create ]

  def index
    index! do |format|
      format.html{ return render :index, :layout => false }
    end
  end

  def create
    create! do |format|
      format.html{ return redirect_to project_updates_path(@project) }
    end
  end

  def destroy
    destroy! do |format|
      return index
    end
  end

  protected
  def set_user_id
    params[:update][:user_id] = session[:user_id]
  end
end
