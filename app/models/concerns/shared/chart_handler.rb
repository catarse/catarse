module Shared::ChartHandler
  extend ActiveSupport::Concern

  included do
    def self.chart
      series = [
        {name: I18n.t('admin.statistics.charts.current_period'), data: {}},
        {name: I18n.t('admin.statistics.charts.last_year'), data: {}}
      ]
      self.all.each do |data|
        series[0][:data][data.label] = data.current_year
        series[1][:data][data.label] = data.last_year
      end
      series
    end

  end
end
