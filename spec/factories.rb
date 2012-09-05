Factory.sequence :name do |n|
  "Foo bar #{n}"
end
Factory.sequence :email do |n|
  "person#{n}@example.com"
end
Factory.sequence :uid do |n|
  "#{n}"
end
Factory.sequence :permalink do |n|
  "foo_page_#{n}"
end
Factory.define :user do |f|
  f.provider "twitter"
  f.uid { Factory.next(:uid) }
  f.name "Foo bar"
  f.email { Factory.next(:email) }
  f.bio "This is Foo bar's biography."
end
Factory.define :category do |f|
  f.name { Factory.next(:name) }
end
Factory.define :project do |f|
  f.name "Foo bar"
  f.permalink { Factory.next(:permalink) }
  f.association :user, :factory => :user
  f.association :category, :factory => :category
  f.about "Foo bar"
  f.headline "Foo bar"
  f.goal 10000
  f.expires_at { 1.month.from_now }
  f.video_url 'http://vimeo.com/17298435'
end
Factory.define :notification do |f|
  f.email_subject "Just a test"
  f.association :user, :factory => :user
  f.email_text "email text"
  f.text "Test :)"
end
Factory.define :reward do |f|
  f.association :project, :factory => :project
  f.minimum_value 1.00
  f.description "Foo bar"
end
Factory.define :backer do |f|
  f.association :project, :factory => :project
  f.association :user, :factory => :user
  f.confirmed true
  f.value 10.00
end
Factory.define :payment_notification do |f|
  f.association :backer, :factory => :backer
  f.extra_data {}
end
Factory.define :oauth_provider do |f|
  f.name 'GitHub'
  f.strategy 'GitHub'
  f.path 'github'
  f.key 'test_key'
  f.secret 'test_secret'
end
Factory.define :configuration do |f|
  f.name 'Foo'
  f.value 'Bar'
end
Factory.define :curated_page do |f|
  f.name 'Foo Page'
  f.permalink { Factory.next(:permalink) }
  f.description 'foo description'
  f.logo File.open("#{Rails.root.to_s}/lib/fixtures/engage.png")
  f.video_url 'http://vimeo.com/28220980'
end
Factory.define :projects_curated_page do |f|
  f.association :project, :factory => :project
  f.association :curated_page, :factory => :curated_page
end

Factory.define :institutional_video do |f|
  f.title "My title"
  f.description "Some Description"
  f.video_url "http://vimeo.com/35492726"
  f.visible false
end

Factory.define :update do |f|
  f.association :project, :factory => :project
  f.association :user, :factory => :user
  f.title "My title"
  f.comment "This is a comment"
  f.comment_html "<p>This is a comment</p>"
end
