class ChannelObserver < ActiveRecord::Observer
  observe :channel

  def after_save(channel)
    if channel.try(:video_url_changed?) && channel.reload
      channel.update_video_embed_url
    end
  end
end
