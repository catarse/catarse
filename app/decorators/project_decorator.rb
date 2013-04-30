class ProjectDecorator < Draper::Decorator
  decorates :project
  include Draper::LazyHelpers

  def remaining_days
    source.time_to_go[:time]
  end

  def display_status
    if source.online?
      (source.reached_goal? ? 'reached_goal' : 'not_reached_goal')
    else
      source.state
    end
  end

  # Method for width of progress bars only
  def display_progress
    return 100 if source.successful? || source.progress > 100
    return 8 if source.progress > 0 and source.progress < 8
    source.progress
  end

  def display_image
    if source.uploaded_image.present?
      source.uploaded_image.project_thumb.url
    elsif source.image_url.present?
      source.image_url
    elsif source.video_thumbnail.url.present?
      source.video_thumbnail.url
    elsif source.video
      source.video.thumbnail_large
    end
  end

  def video_embed_url
    if source.video.instance_of? VideoInfo::Vimeo
      "#{source.video.embed_url}?title=0&amp;byline=0&amp;portrait=0&amp;autoplay=0"
    elsif source.video.instance_of? VideoInfo::Youtube
      source.video.embed_url
    end
  end

  def display_expires_at
    I18n.l(source.expires_at.to_date)
  end

  def display_pledged
    number_to_currency source.pledged, :unit => 'R$', :precision => 0, :delimiter => '.'
  end

  def display_goal
    number_to_currency source.goal, :unit => 'R$', :precision => 0, :delimiter => '.'
  end



  def progress_bar
    width = source.progress > 100 ? 100 : source.progress
    content_tag(:div, id: :progress_wrapper) do
      content_tag(:div, nil, id: :progress, style: "width: #{width}%") 
    end
  end
end

