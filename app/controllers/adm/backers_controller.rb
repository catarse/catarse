class Adm::BackersController < Adm::BaseController
  menu I18n.t("adm.backers.index.menu") => Rails.application.routes.url_helpers.adm_backers_path
  has_scope :by_user_id, :by_key, :user_name_contains, :project_name_contains, :confirmed, :credits, :requested_refund, :refunded
  has_scope :pending_to_refund do |controller, scope, value|
    if value.present?
      scope.pending_to_refund 
    else
      scope
    end
  end
  before_filter :set_title

  def confirm
    resource.confirm!
    flash[:notice] = I18n.t('adm.backers.messages.successful.confirm')
    redirect_to adm_backers_path
  end

  def unconfirm
    resource.unconfirm!
    flash[:notice] = I18n.t('adm.backers.messages.successful.unconfirm')
    redirect_to adm_backers_path
  end

  def change_reward
    resource.change_reward! params[:reward_id]
    flash[:notice] = I18n.t('adm.backers.messages.successful.change_reward')
    redirect_to adm_backers_path
  end

  protected
  def set_title
    @title = t("adm.backers.index.title")
  end

  def collection
    @backers = end_of_association_chain.order("backers.created_at DESC").page(params[:page])
  end
end
