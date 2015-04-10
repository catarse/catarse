class Admin::ContributionsController < Admin::BaseController
  layout 'catarse_bootstrap'
  has_scope :project_name_contains, :search_on_acquirer, :by_user_id, :by_payment_id, :by_payment_method, :user_name_contains, :user_email_contains
  has_scope :between_values, using: [ :start_at, :ends_at ], allow_blank: true
  before_filter :set_title

  def self.contribution_actions
    %w[pay refuse refund trash request_refund].each do |action|
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

  def update
    if params[:contribution]
      Contribution.update(params[:id], params[:contribution])
      head :ok, content_type: "text/html"
    else
      update!
    end
  end

  def change_reward
    resource.change_reward! params[:reward_id]
    flash[:notice] = I18n.t('admin.contributions.messages.successful.change_reward')
    redirect_to admin_contributions_path(params[:local_params])
  end

  protected
  def set_title
    @title = t("admin.contributions.index.title")
  end

  def resource
    Payment.find params[:id]
  end

  def collection
    @contributions = apply_scopes(ContributionDetail).reorder("contribution_details.contribution_id DESC").page(params[:page])
  end
end
