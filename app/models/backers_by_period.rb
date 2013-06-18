class BackersByPeriod < ActiveRecord::Base
  def self.chart
    self.all.reduce([]) do |memo, row|
      memo << {name: I18n.t("adm.statistics.backers_by_week.#{row.series}"), data: {}} unless memo.last && memo.last[:name] == I18n.t("adm.statistics.backers_by_week.#{row.series}")
      memo.last[:data][Date.today - (row[:week] * 7).days] = row[:sum]
      memo
    end
  end
end
