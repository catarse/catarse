module CatarseScripts
  module ApplicationHelper
    include Pagy::Frontend

    def script_status_class(script_status)
      case script_status
      when 'pending'
        'bg-orange-300'
      when 'running'
        'bg-blue-400'
      when 'done'
        'bg-green-500'
      when 'with_error'
        'bg-red-500'
      end
    end
  end
end
