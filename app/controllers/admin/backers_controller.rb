class Admin::BackersController < Admin::BaseController
  add_to_menu "admin.backers.index.menu", :admin_backers_path
  has_scope :by_user_id, :by_key, :user_name_contains, :user_email_contains, :payer_email_contains, :project_name_contains, :confirmed, :credits, :with_state, :by_value
  has_scope :between_values, using: [ :start_at, :ends_at ], allow_blank: true
  before_filter :set_title

  def self.backer_actions
    %w[confirm pendent refund hide cancel push_to_trash].each do |action|
      define_method action do
        resource.send(action)
        flash[:notice] = I18n.t("admin.backers.messages.successful.#{action}")
        redirect_to admin_backers_path(params[:local_params])
      end
    end
  end
  backer_actions

  def change_reward
    resource.change_reward! params[:reward_id]
    flash[:notice] = I18n.t('admin.backers.messages.successful.change_reward')
    redirect_to admin_backers_path(params[:local_params])
  end

  protected
  def set_title
    @title = t("admin.backers.index.title")
  end

  def collection
    @backers = apply_scopes(end_of_association_chain).without_state('deleted').order("backers.created_at DESC").page(params[:page])
  end
end
