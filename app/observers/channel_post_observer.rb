class ChannelPostObserver < ActiveRecord::Observer
  observe :channel_post

  def before_save(channel_post)
    if channel_post.visible
      channel_post.published_at = DateTime.now unless channel_post.published_at.present?
    end
  end

  def after_save(channel_post)
    if channel_post.visible
      channel_post.channel.subscribers.each do |subscriber|
        channel_post.notify_once(
          :channel_post,
          subscriber,
          channel_post,
          {
            from_email: channel_post.channel.email,
            from_name: channel_post.channel.name
          }
        )
      end
    end
  end
end
