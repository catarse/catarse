class Projects::UpdatesController < ApplicationController
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
    @update = parent.updates.create(params[:update].merge!(user: current_user))
    render @update
  end

  def destroy
    destroy!{|format| return index }
  end

  def collection
    @updates ||= end_of_association_chain.visible_to(current_user)
  end
end
