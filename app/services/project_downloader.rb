class ProjectDownloader

  def initialize(resource)
    @resource = resource
  end

  def start!
    update_video_embed_url
    download_video_thumbnail
  end

  def download_video_thumbnail
    @resource.video_thumbnail = open(@resource.video.thumbnail_large) if @resource.video_url.present? && @resource.video
  rescue OpenURI::HTTPError, TypeError => e
    Rails.logger.info "-----> #{e.inspect}"
  end

  def update_video_embed_url
    @resource.video_embed_url = @resource.video.embed_url if @resource.video
  end

end
