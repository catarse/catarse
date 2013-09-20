class ProjectsByPeriod < ActiveRecord::Base
  def self.chart
    self.all.reduce([]) do |memo, row|
      memo << {name: I18n.t("admin.statistics.projects_by_week.#{row.series}"), data: {}} unless memo.last && memo.last[:name] == I18n.t("admin.statistics.projects_by_week.#{row.series}")
      memo.last[:data][Date.today - (row[:week] * 7).days] = row[:count]
      memo
    end
  end
end
