class ProjectBaseWorker
  def resource_action id, action_name
    resource = Project.find id
    Rails.logger.info "[#{action_name} on resource_id -> #{resource.id}] - #{resource.name}"
    resource.send(action_name)
  end
end
