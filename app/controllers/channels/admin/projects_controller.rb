class Channels::Admin::ProjectsController < Admin::BaseController
  menu I18n.t('channels.adm.profile_menu') => Rails.application.routes.url_helpers.edit_channels_profile_path

  has_scope :by_id, :pg_search, :user_name_contains, :order_table, :with_state
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :order_table do |controller, scope, value|
    value.present? ? scope.order_table(value) : scope.order('created_at DESC')
  end

  before_filter do
    @total_projects =  channel.projects.size
  end

  [:approve, :reject, :push_to_draft].each do |name|
    define_method name do
      @project    = channel.projects.find(params[:id])
      @project.send("#{name.to_s}!")
      redirect_to :back
    end
  end

  protected
  def begin_of_association_chain
    channel
  end

  def collection
    @projects = apply_scopes(channel.projects.page(params[:page]))
  end
end
