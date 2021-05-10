# frozen_string_literal: true

FactoryBot.define do
  factory :project_integration do
    association :project
    name { 'GA' }
    data { { data: { id: 'UA-12345678-1' } } }
  end

  factory :coming_soon_integration, class: 'ProjectIntegration' do
    association :project
    name { 'COMING_SOON_LANDING_PAGE' }
    data { { draft_url: "coming_soon_landing_page_#{SecureRandom.hex(4)}" } }
  end
end
