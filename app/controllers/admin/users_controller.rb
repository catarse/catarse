class Admin::UsersController < Admin::BaseController
  layout 'catarse_bootstrap'
  inherit_resources
  add_to_menu "admin.users.index.menu", :admin_users_path
  before_filter :set_title

  has_scope :by_id, :by_name, :by_email, :by_payer_email, :by_key, :has_credits, :has_credits_difference, only: :index

  protected
  def set_title
    @title = t("admin.users.index.title")
  end

  def collection
    @users ||= apply_scopes(end_of_association_chain).order_by(params[:order_by] || 'coalesce(user_totals.sum, 0) DESC').includes(:user_total).page(params[:page])
  end
end

