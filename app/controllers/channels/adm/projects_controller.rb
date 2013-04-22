class Channels::Adm::ProjectsController < Adm::BaseController
  menu I18n.t('channels.adm.menu') => Rails.application.routes.url_helpers.adm_projects_path

  
  has_scope :by_id, :pg_search, :user_name_contains, :order_table, :by_state
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :order_table do |controller, scope, value|
  value.present? ? scope.order_table(value) : scope.order('created_at DESC')
  end



  before_filter do
    @channel        =  Channel.find_by_permalink!(request.subdomain.to_s)
    @total_projects =  @channel.projects.size 
  end

  [:approve, :reject, :push_to_draft].each do |name|
    define_method name do
      @project    = @channel.projects.find(params[:id])
      @project.send("#{name.to_s}!")
      redirect_to :back
    end
  end

  protected
    def begin_of_association_chain
      @channel
    end

    def collection
      @projects = apply_scopes(@channel.projects.page(params[:page]))
    end
  

end
