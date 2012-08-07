class Adm::BackersController < Adm::BaseController
  inherit_resources
  menu I18n.t("admin.backers.menu") => Rails.application.routes.url_helpers.adm_backers_path
  before_filter :set_title

  protected
  def set_title
    @title = t("admin.backers.title")
  end

  def collection
    @backers ||= end_of_association_chain.all
  end
end
