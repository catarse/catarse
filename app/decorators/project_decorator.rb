class ProjectDecorator < Draper::Decorator
  decorates :project
  include Draper::LazyHelpers

  def remaining_days
    time_to_go[:time]
  end

  def display_status
    if source.online?
      (reached_goal? ? 'reached_goal' : 'not_reached_goal')
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
    else
      source.video_thumbnail.url || source.vimeo.thumbnail
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
end

