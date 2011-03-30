module ActionView::Helpers::DateHelper
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    case distance_in_minutes
      when 0..1
        return (distance_in_minutes == 0) ? 'menos de um minuto' : '1 minuto' unless include_seconds
        case distance_in_seconds
          when 0..4   then 'menos de 5 segundos'
          when 5..9   then 'menos de 10 segundos'
          when 10..19 then 'menos de 20 segundos'
          when 20..39 then 'meio minuto'
          when 40..59 then 'menos de um minuto'
        else             '1 minuto'
        end
      when 2..44           then "#{distance_in_minutes} minutos"
      when 45..89          then 'aproximadamente 1 hora'
      when 90..1439        then "aproximadamente #{(distance_in_minutes.to_f / 60.0).round} horas"
      when 1440..2879      then '1 dia'
      when 2880..43199     then "#{(distance_in_minutes / 1440).round} dias"
      when 43200..86399    then 'aproximadamente 1 mês'
      when 86400..525959   then "#{(distance_in_minutes / 43200).round} meses"
      when 525960..1051919 then 'aproximadamente 1 ano'
      else                      "mais de #{(distance_in_minutes / 525960).round} anos"
    end
  end
end