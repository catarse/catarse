module Shared::ChartHandler
  extend ActiveSupport::Concern

  included do
    mattr_accessor :statistic_label, :label_scope

    self.label_scope = 'admin.statistics'

    def self.chart
      self.all.reduce([]) do |memo, row|
        unless memo.last && memo.last[:name] == row.chart_label
          memo.push({ name: row.chart_label, data: {} })
        end

        memo.last[:data][row.data_label] = (row.try(:sum) || row.try(:count))
        memo
      end
    end

    def chart_label
      I18n.t("#{self.statistic_label}.#{self.series}", scope: self.label_scope)
    end

    def data_label
      Date.today - ( self.week * 7 ).days
    end
  end
end
