FactoryGirl.define do
  sequence :name do |n|
    "Foo bar #{n}"
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :uid do |n|
    "#{n}"
  end

  sequence :permalink do |n|
    "foo_page_#{n}"
  end

  factory :user do |f|
    f.name "Foo bar"
    f.password "123456"
    f.email { generate(:email) }
    f.bio "This is Foo bar's biography."
  end

  factory :category do |f|
    f.name_pt { generate(:name) }
  end

  factory :project do |f|
    f.name "Foo bar"
    f.permalink { generate(:permalink) }
    f.association :user, factory: :user
    f.association :category, factory: :category
    f.about "Foo bar"
    f.headline "Foo bar"
    f.goal 10000
    f.online_date Time.now
    f.online_days 5
    f.how_know 'Lorem ipsum'
    f.more_links 'Ipsum dolor'
    f.first_contributions 'Foo bar'
    f.video_url 'http://vimeo.com/17298435'
    f.state 'online'
  end

  factory :channels_subscriber do |f|
    f.association :user
    f.association :channel
  end

  factory :unsubscribe do |f|
    f.association :user, factory: :user
    f.association :project, factory: :project
  end

  factory :notification do |f|
    f.association :user, factory: :user
    f.association :contribution, factory: :contribution
    f.association :project, factory: :project
    f.template_name 'project_success'
    f.origin_name 'Foo Bar'
    f.origin_email 'foo@bar.com'
    f.locale 'pt'
  end

  factory :reward do |f|
    f.association :project, factory: :project
    f.minimum_value 10.00
    f.description "Foo bar"
    f.days_to_delivery 10
  end

  factory :contribution do |f|
    f.association :project, factory: :project
    f.association :user, factory: :user
    f.confirmed_at Time.now
    f.value 10.00
    f.state 'confirmed'
    f.credits false
    f.payment_id '1.2.3'
  end

  factory :payment_notification do |f|
    f.association :contribution, factory: :contribution
    f.extra_data {}
  end

  factory :authorization do |f|
    f.association :oauth_provider
    f.association :user
    f.uid 'Foo'
  end

  factory :oauth_provider do |f|
    f.name 'facebook'
    f.strategy 'GitHub'
    f.path 'github'
    f.key 'test_key'
    f.secret 'test_secret'
  end

  factory :configuration do |f|
    f.name 'Foo'
    f.value 'Bar'
  end

  factory :institutional_video do |f|
    f.title "My title"
    f.description "Some Description"
    f.video_url "http://vimeo.com/35492726"
    f.visible false
  end

  factory :update do |f|
    f.association :project, factory: :project
    f.association :user, factory: :user
    f.title "My title"
    f.comment "This is a comment"
    f.comment_html "<p>This is a comment</p>"
  end

  factory :channel do
    name "Test"
    email "email+channel@foo.bar"
    description "Lorem Ipsum"
    sequence(:permalink) { |n| "#{n}-test-page" }
  end

  factory :state do
    name "RJ"
    acronym "RJ"
  end

  factory :channel_post do |f|
    f.association :user, factory: :user
    f.association :channel, factory: :channel
    title "My title"
    f.body "This is a comment"
    f.body_html "<p>This is a comment</p>"
  end

end

