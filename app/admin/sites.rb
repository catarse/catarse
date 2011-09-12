ActiveAdmin.register Site do
  controller.authorize_resource

  index do
    column :name do |site|
      link_to site.name, admin_site_path(site)
    end
    column :host
    default_actions
  end
  
  form do |f|
    f.inputs do
      f.input :name, :as => :string
      f.input :title, :as => :string
      f.input :path, :as => :string
      f.input :host, :as => :string
      f.input :gender, :as => :string
      f.input :email, :as => :string
      f.input :twitter, :as => :string
      f.input :facebook, :as => :string
      f.input :blog, :as => :string
      f.input :auth_gateway
      f.input :port, :as => :string
    end
    f.buttons do
      f.submit
    end
  end
end