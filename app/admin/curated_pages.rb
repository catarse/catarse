ActiveAdmin.register CuratedPage do
  controller.authorize_resource
  scope_to :current_site

  index do
    column :name do |site|
      link_to site.name, admin_site_path(site)
    end
    default_actions
  end

  form :partial => "form"
  # form :html => {:multipart => true} do |f|
  #   f.inputs do
  #     f.input :name
  #     f.input :description
  #     f.input :logo, :as => :file
  #     f.input :video_url
  #   end
  #   
  #   f.buttons do
  #     f.submit
  #   end
  # end
end