FactoryGirl.define do
  sequence :name do |n|
    "Foo bar #{n}"
  end

  sequence :bank_number do |n|
    "0000#{n}"
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

  factory :channel_partner do |f|
    f.url "http://google.com"
    f.image File.open("#{Rails.root}/spec/support/testimg.png")
    f.association :channel
  end

  factory :category_follower do |f|
    f.association :user
    f.association :category
  end

  factory :user_without_bank_data, class: User do |f|
    f.name "Foo bar"
    f.full_name "Foo bar"
    f.password "123456"
    f.cpf "123456"
    f.uploaded_image File.open("#{Rails.root}/spec/support/testimg.png")
    f.email { generate(:email) }
    f.bio "This is Foo bar's biography."
    f.address_street 'fooo'
    f.address_number '123'
    f.address_city 'fooo bar'
    f.address_state 'fooo'
    f.address_neighbourhood 'bar'
    f.address_zip_code '123344333'
    f.phone_number '1233443355'
  end

  factory :user do |f|
    f.association :bank_account
    f.name "Foo bar"
    f.full_name "Foo bar"
    f.password "123456"
    f.cpf "123456"
    f.uploaded_image File.open("#{Rails.root}/spec/support/testimg.png")
    f.email { generate(:email) }
    f.bio "This is Foo bar's biography."
    f.address_street 'fooo'
    f.address_number '123'
    f.address_city 'fooo bar'
    f.address_state 'fooo'
    f.address_neighbourhood 'bar'
    f.address_zip_code '123344333'
    f.phone_number '1233443355'
  end

  factory :category do |f|
    f.name_pt { generate(:name) }
  end

  factory :project do |f|
    #after(:create) do |project|
    #  create(:reward, project: project)
    #  if project.state == 'change_to_online_after_create'
    #    project.update_attributes(state: 'online')
    #  end
    #end
    f.name "Foo bar"
    f.permalink { generate(:permalink) }
    f.association :user
    f.association :category
    f.about "Foo bar"
    f.headline "Foo bar"
    f.goal 10000
    f.online_date Time.now
    f.online_days 5
    f.more_links 'Ipsum dolor'
    f.first_contributions 'Foo bar'
    f.video_url 'http://vimeo.com/17298435'
    f.state 'online'
    f.budget '1000'
    f.uploaded_image File.open("#{Rails.root}/spec/support/testimg.png")
  end

  factory :project_budget do |f|
    f.association :project
    f.name "Foo Bar"
    f.value "10"
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
    f.deliver_at 10.days.from_now
  end

  factory :rewards, class: Reward do |f|
    f.minimum_value 10.00
    f.description "Foo bar"
    f.deliver_at 10.days.from_now
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

  factory :project_post do |f|
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

  factory :bank do
    name "Foo"
    code { generate(:bank_number) }
  end

  factory :bank_account do |f|
    #f.association :user, factory: :user
    f.association :bank, factory: :bank
    owner_name "Foo"
    owner_document "000"
    account_digit "1"
    agency "1"
    agency_digit "1"
    account "1"
  end

  factory :single_bank_account, class: BankAccount do |f|
    f.association :bank, factory: :bank
    owner_name "Foo"
    owner_document "000"
    account_digit "1"
    agency "1"
    account '1'
  end

  factory :channel_post do |f|
    f.association :user, factory: :user
    f.association :channel, factory: :channel
    title "My title"
    f.body "This is a comment"
    f.body_html "<p>This is a comment</p>"
  end

end

