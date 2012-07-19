module ProjectPresenter
  class Home

    attr_accessor :recommended_project, :second_project,
                  :third_project, :fourth_project, :expiring, :recent, :current_user, :first_project


    def initialize(options)
      @current_user ||= options[:current_user]
    end

    def current_user
      @current_user
    end

    def fetch_projects
      collection_projects = Project.includes(:user, :category, :backer_total).
                                    recommended.
                                    visible.
                                    not_expired
      unless collection_projects.empty?
        if current_user and current_user.recommended_project
          @recommended_project = current_user.recommended_project
          collection_projects = collection_projects.where("id != #{current_user.recommended_project.id}")
        end
        collection_projects = collection_projects.where("category_id != #{@recommended_project.category_id}") if @recommended_project
        @first_project = collection_projects.all[rand(collection_projects.length)]
        collection_projects = collection_projects.where("id != #{@first_project.id}") if @first_project
        @second_project = collection_projects.all[rand(collection_projects.length)]
        collection_projects = collection_projects.where("category_id != #{@second_project.category_id}") if @second_project
        @third_project = collection_projects.all[rand(collection_projects.length)]
        collection_projects = collection_projects.where("category_id != #{@third_project.category_id}") if @third_project
        @fourth_project = collection_projects.all[rand(collection_projects.length)]
      end

      project_ids = []
      project_ids << @recommended_project.id if @recommended_project
      project_ids << @first_project.id if @first_project
      project_ids << @second_project.id if @second_project
      project_ids << @third_project.id if @third_project
      project_ids << @fourth_project.id if @fourth_project
      project_ids = project_ids.join(',')
      project_ids = "id NOT IN (#{project_ids})" unless project_ids.blank?

      @expiring = Project.includes(:user, :category, :backer_total).where(project_ids).visible.expiring.order('date(expires_at), random()').limit(3).all
      @recent = Project.includes(:user, :category, :backer_total).where(project_ids).recent.visible.not_expiring.order('date(created_at), random()').limit(3).all
    end
  end
end
