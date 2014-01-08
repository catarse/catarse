class Channels::Admin::ProjectsController < Admin::BaseController
  layout 'catarse_bootstrap'
  has_scope :by_id, :pg_search, :user_name_contains, :order_by, :with_state
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true

  before_filter do
    @total_projects =  channel.projects.size
  end

  [:approve, :reject, :push_to_draft, :push_to_trash].each do |name|
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
