class ProjectBaseWorker
  private
  def resource id
    @resource ||= Project.find id
  end
end
