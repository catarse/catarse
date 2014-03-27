class ProjectsInAnalysisByPeriod < ActiveRecord::Base
  include Shared::ChartHandler

  self.statistic_label = 'projects_by_week'
end
