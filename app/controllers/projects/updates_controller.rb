class Projects::UpdatesController < ApplicationController
  after_filter :verify_authorized, except: %i[index show]
  after_action :verify_policy_scoped, only: %i[index]
  inherit_resources

  actions :index, :create, :destroy
  belongs_to :project

  def show
    render resource
  end

  def index
    render collection.page(params[:page]).per(3)
  end

  def create
    @update = parent.updates.new(update_params)
    authorize @update
    @update.save
    render @update
  end

  def destroy
    authorize resource
    destroy!{ return index }
  end

  def collection
    @updates ||= policy_scope(end_of_association_chain).ordered
  end

  protected

  def update_params
    params.require(:update).permit(:title, :comment, :user_id, :exclusive).merge!(user_id: current_user.try(:id))
  end

end
