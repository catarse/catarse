class Users::ProjectsController < ApplicationController
  after_filter :verify_authorized, except: [:index]
  after_filter :verify_policy_scoped, only: [:index]

  inherit_resources
  actions :index
  belongs_to :user

  def index
    collection
    render layout: false
  end

  protected

  def policy_scope(scope)
    @_policy_scoped = true
    ProjectPolicy::UserScope.new(current_user, parent, scope).resolve
  end

  def collection
    @projects ||= policy_scope(end_of_association_chain).page(params[:page]).per(10)
  end

end
