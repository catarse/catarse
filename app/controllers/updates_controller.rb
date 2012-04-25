class UpdatesController < ApplicationController
  inherit_resources

  actions :index, :create, :destroy
  respond_to :json, :only => [ :index, :destroy ]
  respond_to :html, :only => [ :create, :index ]
  belongs_to :project

  before_filter :set_user_id, :only => [ :create ]

  def index
    index! do |format|
      format.html do
        return render :layout => false
      end
    end
  end

  def create
    create! do |format|
      format.html{ return redirect_to project_updates_path(@project) }
    end
  end

  protected
  def set_user_id
    params[:update][:user_id] = session[:user_id]
  end
end
