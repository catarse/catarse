ActiveAdmin.register Reward do
  controller.authorize_resource

  index do
    column :project_name do |reward|
      reward.project.name
    end
    column :minimum_value
    column :maximum_backers
    column :description
    default_actions
  end
end