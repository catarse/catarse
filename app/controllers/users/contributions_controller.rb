class Users::ContributionsController < ApplicationController
  after_filter :verify_authorized, except: %i[index]
  inherit_resources
  defaults resource_class: Contribution
  belongs_to :user
  actions :index

  def index
    render layout: false
  end

  def request_refund
    authorize resource
    if resource.value > resource.user.user_total.credits
      flash[:failure] = I18n.t('credits.index.insufficient_credits')
    elsif can?(:request_refund, resource) && resource.can_request_refund?
      resource.request_refund!
      flash[:notice] = I18n.t('credits.index.refunded')
    end

    redirect_to user_path(parent, anchor: 'credits')
  end

  protected
  def collection
    @contributions ||= policy_scoped(end_of_association_chain).order("created_at DESC, confirmed_at DESC").includes(:user, :reward, project: [:user, :category, :project_total]).page(params[:page]).per(10)
  end
end
