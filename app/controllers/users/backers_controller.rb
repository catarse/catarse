class Users::BackersController < ApplicationController
  inherit_resources
  defaults resource_class: Backer, collection_name: 'backs', instance_name: 'back'
  belongs_to :user
  actions :index

  def index
    render layout: false
  end

  def request_refund
    authorize! :request_refund, resource
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
    @backs = end_of_association_chain.available_to_count.order("confirmed_at DESC")
    @backs = @backs.not_anonymous if can? :manage, @user
    @backs = @backs.includes(:user, :reward, project: [:user, :category, :project_total]).page(params[:page]).per(10)
  end
end
