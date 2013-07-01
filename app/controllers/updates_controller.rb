class UpdatesController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  actions :index, :create, :destroy
  respond_to :html, only: [ :index, :create, :destroy ]
  belongs_to :project

  def index
    index! do |format|
      format.html{ return render end_of_association_chain.page(params[:page]).per(3) }
    end
  end

  def create
    @update = parent.updates.new(params[:update])
    @update.user = current_user
    create! do |format|
      format.html{ return index }
    end
  end

  def destroy
    destroy!{|format| return index }
  end
end
