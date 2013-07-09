class UpdatesController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  actions :index, :create, :destroy
  belongs_to :project

  def show
    render resource
  end

  def index
    render end_of_association_chain.page(params[:page]).per(3)
  end

  def create
    @update = parent.updates.new(params[:update])
    @update.user = current_user
    create! do |format|
      format.html{ return render @update }
    end
  end

  def destroy
    destroy!{|format| return index }
  end
end
