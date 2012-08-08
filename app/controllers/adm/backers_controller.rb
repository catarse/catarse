class Adm::BackersController < Adm::BaseController
  inherit_resources
  menu I18n.t("admin.backers.menu") => Rails.application.routes.url_helpers.adm_backers_path
  before_filter :set_title

  protected
  def set_title
    @title = t("admin.backers.title")
  end

  def collection
    @search = Backer.search(params[:search])
    @backers = @search.order("created_at DESC").page(params[:page])
  end
end
