class Adm::BackersController < Adm::BaseController
  menu I18n.t("adm.backers.index.menu") => Rails.application.routes.url_helpers.adm_backers_path
  has_scope :by_user_id, :by_key, :user_name_contains, :project_name_contains, :confirmed, :credits, :with_state, :by_value
  has_scope :between_values, using: [ :start_at, :ends_at ], allow_blank: true
  before_filter :set_title

  def self.backer_actions
    %w[confirm pendent refund hide cancel push_to_trash].each do |action|
      define_method action do
        resource.send(action)
        flash[:notice] = I18n.t("adm.backers.messages.successful.#{action}")
        redirect_to adm_backers_path(params[:local_params])
      end
    end
  end
  backer_actions

  def change_reward
    resource.change_reward! params[:reward_id]
    flash[:notice] = I18n.t('adm.backers.messages.successful.change_reward')
    redirect_to adm_backers_path(params[:local_params])
  end

  protected
  def set_title
    @title = t("adm.backers.index.title")
  end

  def collection
    @backers = apply_scopes(end_of_association_chain).without_state('deleted').order("backers.created_at DESC").page(params[:page])
  end
end
