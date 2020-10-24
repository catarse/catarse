# frozen_string_literal: true

class ProjectDecorator < Draper::Decorator
  decorates :project
  include Draper::LazyHelpers

  def show_city
    if object.city.present?
      object.city.show_name
    elsif object.user.address_city.present? && object.user.address_state.present?
      "#{object.user.address_city.capitalize}, #{object.user.address_state} "
    end
  end

  def elapsed_time
    get_interval_from_db 'elapsed_time_json'
  end

  def time_to_go
    get_interval_from_db 'remaining_time_json'
  end

  def display_status
    object.state
  end

  def display_mailer_status
    case project.state
    when 'successful' then 'financiado'
    when 'failed' then 'não financiado'
    when 'rejected' then 'cancelado'
    end
  end

  def display_card_status
    if object.online?
      (object.reached_goal? ? 'reached_goal' : 'not_reached_goal')
    else
      object.state
    end
  end

  def display_image(version = 'project_thumb')
    use_uploaded_image(version) || use_video_tumbnail(version)
  end

  def display_expires_at
    object.expires_at ? I18n.l(object.pluck_from_database('zone_expires_at').to_date) : ''
  end

  def progress
    return 0 if object.goal == 0.0 || object.goal.nil?
    ((object.pledged / object.goal) * 100).to_i
  end

  def display_pledged
    number_to_currency object.pledged.floor
  end

  def display_pledged_with_cents
    number_to_currency object.pledged, precision: 2
  end

  def display_goal
    number_to_currency object.goal
  end

  def progress_bar
    width = object.progress > 100 ? 100 : object.progress
    content_tag(:div, nil, id: :progress, class: 'meter-fill', style: "width: #{width}%;")
  end

  def status_flag
    content_tag(:div, class: [:status_flag]) do
      if object.successful?
        image_tag "successful.#{I18n.locale}.png"
      elsif object.failed?
        image_tag "not_successful.#{I18n.locale}.png"
      elsif object.waiting_funds?
        image_tag "waiting_confirmation.#{I18n.locale}.png"
      end
    end
  end

  private

  def get_interval_from_db(column)
    time_json = object.pluck_from_database(column)
    time_json = JSON.parse(time_json) if time_json.is_a?(String)
    {
      time: time_json.try(:[], 'total'),
      unit: pluralize_without_number(time_json.try(:[], 'total'), I18n.t("datetime.prompts.#{time_json.try(:[], 'unit')}").downcase)
    }
  end

  def use_uploaded_image(version)
    object.uploaded_image.send(version).url if object.uploaded_image.present?
  end

  def use_video_tumbnail(version)
    if object.video_thumbnail.url.present?
      object.video_thumbnail.send(version).url
    elsif object.video
      object.video.thumbnail_large
    end
  rescue
    nil
  end
end
