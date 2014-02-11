class Users::ContributionsController < ApplicationController
  after_filter :verify_authorized, except: [:index]
  after_filter :verify_policy_scoped, only: [:index]
  inherit_resources
  defaults resource_class: Contribution
  belongs_to :user
  actions :index

  def index
    collection
    render layout: false
  end

  def request_refund
    authorize resource
    if resource.value > resource.user.user_total.credits || !resource.request_refund
      flash[:failure] = I18n.t('credits.index.insufficient_credits')
    else
      flash[:notice] = I18n.t('credits.index.refunded')
    end

    redirect_to user_path(parent, anchor: 'credits')
  end

  protected
  def policy_scope(scope)
    @_policy_scoped = true
    ContributionPolicy::UserScope.new(current_user, scope).resolve
  end

  def collection
    @contributions ||= policy_scope(end_of_association_chain).order("created_at DESC, confirmed_at DESC").includes(:user, :reward, project: [:user, :category, :project_total]).page(params[:page]).per(10)
  end
end
