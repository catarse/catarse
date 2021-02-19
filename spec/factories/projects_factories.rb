# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    # after(:create) do |project|
    #  create(:reward, project: project)
    #  if project.state == 'change_to_online_after_create'
    #    project.update(state: 'online')
    #  end
    # end
    name { 'Foo bar' }
    permalink { generate(:permalink) }
    association :user
    association :category
    association :city
    about_html { 'Foo bar' }
    headline { 'Foo bar' }
    mode { 'aon' }
    goal { 10_000 }
    online_days { 5 }
    more_links { 'Ipsum dolor' }
    video_url { 'http://vimeo.com/17298435' }
    state { 'online' }
    budget { '1000' }
    uploaded_image { File.open('spec/fixtures/files/testimg.png') }
    content_rating { 1 }

    after :create do |project|
      if project.project_transitions.where(to_state: project.state).blank?
        create(:project_transition, to_state: project.state, project: project)
      end

      # should set expires_at when create a project in these states
      if %w[online waiting_funds failed
            successful].include?(project.state) && project.online_days.present? && project.online_at.present?
        project.expires_at = (project.online_at + project.online_days.days).end_of_day
        project.save
      end
    end

    after :build do |project|
      project.rewards.build(deliver_at: 1.year.from_now, minimum_value: 10, description: 'test',
                            shipping_options: 'free'
                           )
    end
  end
end
