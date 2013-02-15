class Adm::BackersController < Adm::BaseController
  menu I18n.t("adm.backers.index.menu") => Rails.application.routes.url_helpers.adm_backers_path
  has_scope :by_id, :by_key, :user_name_contains, :project_name_contains, :confirmed, :credits, :requested_refund, :refunded
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

  protected
  def set_title
    @title = t("adm.backers.index.title")
  end

  def collection
    @search = apply_scopes(Backer)
    @backers = @search.order("backers.created_at DESC").page(params[:page])
  end
end
