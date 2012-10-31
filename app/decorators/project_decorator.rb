class ProjectDecorator < Draper::Base
  decorates :project
  include Draper::LazyHelpers

  def display_status
    if successful? and expired?
      'successful'
    elsif expired?
      'expired'
    elsif waiting_confirmation?
      'waiting_confirmation'
    elsif in_time?
      'in_time'
    end
  end

  def display_progress
    return 100 if successful?
    return 8 if progress > 0 and progress < 8
    progress
  end

  def display_image
    image_url || (video_thumbnail ? video_thumbnail.url : 'user.png')
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

