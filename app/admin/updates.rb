ActiveAdmin.register Update do
  filter :project

  index do
    column :id
    column :comment
  end
end
