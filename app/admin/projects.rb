ActiveAdmin.register Project do

  scope_to :current_site

  index do
    column :name do |project|
      link_to project.title, admin_project_path(project)
    end
    column :headline
    default_actions
  end

end
