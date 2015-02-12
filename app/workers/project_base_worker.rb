class ProjectBaseWorker
  def resource id
    Rails.logger.info "[loading resource_id -> #{id}]"
    @resource ||= Project.find id
  end
end
