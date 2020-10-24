FactoryBot.define do
  factory :project_report_export do
    association :project
    report_type_ext { 'csv' }
    report_type { 'SubscriptionMonthlyReportForProjectOwner' }
  end
end
