ActiveAdmin.register CuratedPage do
  controller.authorize_resource

  index do
    column :name do |site|
      link_to site.name, admin_site_path(site)
    end
    default_actions
  end

end