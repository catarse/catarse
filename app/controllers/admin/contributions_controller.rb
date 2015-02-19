class Admin::ContributionsController < Admin::BaseController
  layout 'catarse_bootstrap'
  has_scope :project_name_contains, :with_state, :search_on_acquirer, :by_user_id, :by_payment_id, :by_payment_method, :user_name_contains, :user_email_contains
  has_scope :credits, type: :boolean
  has_scope :between_values, using: [ :start_at, :ends_at ], allow_blank: true
  before_filter :set_title

  def self.contribution_actions
    %w[confirm pendent refund hide cancel push_to_trash request_refund].each do |action|
      define_method action do
        if resource.send(action)
          flash[:notice] = I18n.t("admin.contributions.messages.successful.#{action}")
        else
          flash[:notice] = t("activerecord.errors.models.contribution")
        end
        redirect_to admin_contributions_path(params[:local_params])
      end
    end
  end
  contribution_actions

  def change_reward
    resource.change_reward! params[:reward_id]
    flash[:notice] = I18n.t('admin.contributions.messages.successful.change_reward')
    redirect_to admin_contributions_path(params[:local_params])
  end

  protected
  def set_title
    @title = t("admin.contributions.index.title")
  end

  def collection
    @contributions = apply_scopes(end_of_association_chain).without_state('deleted').reorder("contributions.created_at DESC").page(params[:page])
  end
end
