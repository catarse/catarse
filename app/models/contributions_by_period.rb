class ContributionsByPeriod < ActiveRecord::Base
  include Shared::ChartHandler

  self.statistic_label = 'contributions_by_week'
end
