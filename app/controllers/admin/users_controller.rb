class Admin::UsersController < Admin::BaseController
  layout 'catarse_bootstrap'
  inherit_resources
  has_scope :by_id, :by_name, :by_email, :by_payer_email, :by_key, only: :index
  has_scope :has_credits, type: :boolean, only: :index

  protected
  def collection
    @users ||= apply_scopes(end_of_association_chain.joins(:user_total)).order_by(params[:order_by] || 'coalesce(user_totals.sum, 0) DESC').includes(:user_total).page(params[:page])
  end
end

