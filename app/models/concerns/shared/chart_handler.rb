module Shared::ChartHandler
  extend ActiveSupport::Concern

  included do
    def self.chart
      series = [
        {name: 'Ano atual', data: {}},
        {name: 'Ano anterior', data: {}}
      ]
      self.all.each do |data|
        series[0][:data][data.label] = data.current_year
        series[1][:data][data.label] = data.last_year
      end
      series
    end

  end
end
