ActiveAdmin.register User do
  controller.authorize_resource

  scope :primary
  scope :backers

  index do
    column :name do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name, :as => :string
      f.input :full_name, :as => :string
      f.input :nickname, :as => :string
      f.input :bio, :as => :text
      f.input :newsletter
      f.input :project_updates
      f.input :admin
      f.input :locale, :as => :string
    end

    f.buttons do
      f.submit
    end
  end
end
