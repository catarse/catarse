class ProjectDecorator < Draper::Base
  decorates :project
  include Draper::LazyHelpers

  def remaining_days
    time_to_go[:time]
  end

  def display_status
    if online?
      (reached_goal? ? 'reached_goal' : 'not_reached_goal')
    else
      state
    end
  end

  # Method for width of progress bars only
  def display_progress
    return 100 if successful? || progress > 100
    return 8 if progress > 0 and progress < 8
    progress
  end

  def display_image
    if uploaded_image.present?
      uploaded_image.project_thumb.url
    elsif image_url.present?
      image_url
    else
      video_thumbnail.url || vimeo.thumbnail
    end
  end

  def display_expires_at
    I18n.l(expires_at.to_date)
  end

  def display_pledged
    number_to_currency pledged, :unit => 'R$', :precision => 0, :delimiter => '.'
  end

  def display_goal
    number_to_currency goal, :unit => 'R$', :precision => 0, :delimiter => '.'
  end
end

