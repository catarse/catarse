module ProjectPresenter
  class Home

    attr_accessor :recommended_project, :project_of_day, :second_project,
                  :third_project, :fourth_project, :expiring, :recent, :current_user, :first_project


    def initialize(options)
      @current_user ||= options[:current_user]
    end

    def current_user
      @current_user
    end

    def fetch_projects
      collection_projects = Project.includes(:user, :category).
                                    recommended.
                                    visible.
                                    not_expired.
                                    order('"order"')
      unless collection_projects.empty?
        home_page_projects = collection_projects.home_page
        if current_user and current_user.recommended_project
          @recommended_project = current_user.recommended_project
          home_page_projects = home_page_projects.where("id != #{current_user.recommended_project.id}")
          collection_projects = collection_projects.where("id != #{current_user.recommended_project.id}")
        end
        category_projects = collection_projects
        category_projects = category_projects.where("category_id != #{@recommended_project.category_id}") if @recommended_project
        @project_of_day = home_page_projects.first
        category_projects = category_projects.where("id != #{@project_of_day.id}") if @project_of_day
        @first_project = category_projects.all[rand(category_projects.length)]
        category_projects = category_projects.where("id != #{@first_project.id}") if @project_of_day
        @second_project = category_projects.all[rand(category_projects.length)]
        category_projects = category_projects.where("category_id != #{@second_project.category_id}") if @second_project
        @third_project = category_projects.all[rand(category_projects.length)]
        unless @recommended_project
          category_projects = category_projects.where("category_id != #{@third_project.category_id}") if @third_project
          @fourth_project = category_projects.all[rand(category_projects.length)]
        end
      end

      project_ids = []
      project_ids << @recommended_project.id if @recommended_project
      project_ids << @project_of_the_day.id if @project_of_the_day
      project_ids << @second_project.id if @second_project
      project_ids << @third_project.id if @third_project
      project_ids << @fourth_project.id if @fourth_project
      project_ids = project_ids.join(',')
      project_ids = "id NOT IN (#{project_ids})" unless project_ids.blank?

      @expiring = Project.includes(:user, :category).where(project_ids).visible.expiring.not_expired.order('date(expires_at), random()').limit(3).all
      @recent = Project.includes(:user, :category).where(project_ids).recent.visible.not_expiring.not_expired.order('date(created_at), random()').limit(3).all
    end
  end
end