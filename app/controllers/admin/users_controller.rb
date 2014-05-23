class Admin::UsersController < Admin::BaseController
  layout 'catarse_bootstrap'
  inherit_resources
  has_scope :by_id, :by_name, :by_email, :by_payer_email, :by_key, :has_credits, :has_credits_difference, only: :index

  protected
  def collection
    @users ||= apply_scopes(end_of_association_chain).order_by(params[:order_by] || 'coalesce(user_totals.sum, 0) DESC').includes(:user_total).page(params[:page])
  end
end

