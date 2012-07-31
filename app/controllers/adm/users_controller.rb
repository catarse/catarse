class Adm::UsersController < Adm::BaseController
  inherit_resources
  menu I18n.t("admin.users.menu") => Rails.application.routes.url_helpers.adm_users_path
  before_filter :set_title
  before_filter :set_totals

  has_scope :by_id, :by_name, :by_email, :by_key, :has_credits, :only => :index

  protected
  def set_totals
    @total_users = end_of_association_chain.count
    @total_backs
    @total_backed
    @total_users
    @total_credits_table
  end

  def set_title
    @title = t("admin.users.title")
  end

  def collection
    @users ||= end_of_association_chain.page(params[:page])
  end
end

