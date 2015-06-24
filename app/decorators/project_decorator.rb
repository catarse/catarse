class ProjectDecorator < Draper::Decorator
  decorates :project
  include Draper::LazyHelpers

  def remaining_text
    pluralize_without_number(source.time_to_go[:time], I18n.t('remaining_singular'), I18n.t('remaining_plural'))
  end

  def state_warning_template
    "#{source.state}_warning"
  end

  def time_to_go
    time_and_unit = nil
    %w(day hour minute second).detect do |unit|
      time_and_unit = time_to_go_for unit
    end
    time_and_unit || time_and_unit_attributes(0, 'second')
  end

  def remaining_days
    source.time_to_go[:time]
  end

  def display_card_class
    default_card = "card u-radius zindex-10"
    aditional = ""
    if source.waiting_funds?
      aditional = 'card-waiting'
    elsif source.successful?
      aditional = 'card-success'
    elsif source.failed?
      aditional = 'card-error'
    elsif source.draft? || source.in_analysis? || source.approved?
      aditional = 'card-dark'
    else
      default_card = ""
    end
    "#{default_card} #{aditional}"
  end

  def display_status
    source.state
  end

  def display_card_status
    if source.online?
      (source.reached_goal? ? 'reached_goal' : 'not_reached_goal')
    else
      source.state
    end
  end

  def display_image(version = 'project_thumb' )
    use_uploaded_image(version) || use_video_tumbnail(version)
  end

  def display_expires_at
    source.expires_at ? I18n.l(source.expires_at.in_time_zone.to_date) : ''
  end

  def display_online_date
    source.online_date ? I18n.l(source.online_date.to_date) : ''
  end

  def progress
    return 0 if source.goal == 0.0 || source.goal.nil?
    ((source.pledged / source.goal) * 100).to_i
  end

  def display_pledged
    number_to_currency source.pledged.floor
  end

  def display_pledged_with_cents
    number_to_currency source.pledged, precision: 2
  end

  def status_icon_for group_name
    if source.errors.present?
      has_error = source.errors.any? do |error|
        source.error_included_on_group?(error, group_name)
      end

      if has_error
        content_tag(:span, '', class: 'fa fa-exclamation-circle fa-fw fa-lg text-error')
      else
        content_tag(:span, '', class: 'fa fa-check-circle fa-fw fa-lg text-success') unless source.published?
      end
    end
  end

  def display_errors group_name
    #source.valid?
    if source.errors.present?
      error_messages = ''
      source.errors.each do |error|
        if source.error_included_on_group?(error, group_name)
          error_messages += content_tag(:div, source.errors[error][0], class: 'fontsize-smaller')
        end
      end

      unless error_messages.blank?
        content_tag(:div, class: 'card card-error u-radius zindex-10 u-marginbottom-30') do
          content_tag(:div, I18n.t('failure_title'), class: 'fontsize-smaller fontweight-bold u-marginbottom-10') +
          error_messages.html_safe
        end
      end
    end
  end

  def display_goal
    number_to_currency source.goal
  end

  def progress_bar
    width = source.progress > 100 ? 100 : source.progress
    content_tag(:div, nil, id: :progress, class: 'meter-fill', style: "width: #{width}%;")
  end


  def status_flag
    content_tag(:div, class: [:status_flag]) do
      if source.successful?
        image_tag "successful.#{I18n.locale}.png"
      elsif source.failed?
        image_tag "not_successful.#{I18n.locale}.png"
      elsif source.waiting_funds?
        image_tag "waiting_confirmation.#{I18n.locale}.png"
      end
    end

  end

  private

  def use_uploaded_image(version)
    source.uploaded_image.send(version).url if source.uploaded_image.present?
  end

  def use_video_tumbnail(version)
    if source.video_thumbnail.url.present?
      source.video_thumbnail.send(version).url
    elsif source.video
      source.video.thumbnail_large
    end
  rescue
    nil
  end

  def time_to_go_for(unit)
    time = 1.send(unit)

    if source.expires_at.to_i >= time.from_now.to_i
      time = ((source.expires_at - Time.current).abs / time).floor
      time_and_unit_attributes time, unit
    end
  end

  def time_and_unit_attributes(time, unit)
    { time: time, unit: pluralize_without_number(time, I18n.t("datetime.prompts.#{unit}").downcase) }
  end
end

