FactoryBot.define do
  factory :flexible_project do
    association :user
    association :category
    association :city

    state { 'draft' }
    mode { 'flex' }
    name { 'Foo bar' }
    permalink { generate(:permalink) }
    about_html { 'Foo bar' }
    headline { 'Foo bar' }
    goal { 10_000 }
    online_days { 5 }
    more_links { 'Ipsum dolor' }
    video_url { 'http://vimeo.com/17298435' }
    budget { '1000' }
    uploaded_image { File.open('spec/fixtures/files/testimg.png') }
    content_rating { 1 }

    after :create do |flex_project|
      FactoryBot.create(:project_transition, { to_state: flex_project.state, project: flex_project })
    end
  end
end
