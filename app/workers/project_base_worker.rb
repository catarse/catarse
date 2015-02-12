class ProjectBaseWorker
  def resource id
    resource = Project.find id
    Rails.logger.info "[loading resource_id -> #{resource.id}] - #{resource.name}"
  end
end
