ActiveAdmin.register Project do
  controller.authorize_resource

  scope_to :current_site

  index do
    column :name do |project|
      link_to project.name, admin_project_path(project)
    end
    column :headline
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :user
      f.input :category
      f.input :curated_page
      f.input :name, :as => :string
      f.input :goal
      f.input :expires_at
      f.input :about
      f.input :headline
      f.input :curated_page_description
      f.input :video_url, :as => :string
      f.input :can_finish
      f.input :finished
    end

    f.buttons do
      f.submit
    end
  end
  

end
