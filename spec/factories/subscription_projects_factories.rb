FactoryBot.define do
  factory :subscription_project do
    association :category
    association :city
    association :user

    state { 'draft' }
    mode { 'sub' }
    name { 'Foo bar' }
    permalink { generate(:permalink) }
    about_html { 'Foo bar' }
    headline { 'Foo bar' }
    online_days { 5 }
    more_links { 'Ipsum dolor' }
    video_url { 'http://vimeo.com/17298435' }
    budget { '1000' }
    uploaded_image { File.open('spec/fixtures/files/testimg.png') }
    content_rating { 1 }

    after :build do |project|
      project.goals.build(description: 'test', value: 10, title: 'bar')
    end
  end
end
