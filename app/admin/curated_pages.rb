ActiveAdmin.register CuratedPage do
  controller.authorize_resource
  scope :visible
  scope :not_visible

  index do
    column :name
    column :permalink
    column :visible
    default_actions
  end

  #form :partial => "form"
  form :html => {:multipart => true} do |f|
    f.inputs do
      f.input :name
      f.input :permalink
      f.input :site_url
      f.input :description, :as => :text
      f.input :logo, :as => :file
      f.input :video_url
      f.input :visible
    end
    f.buttons do
      f.submit
    end
  end
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
end
