Factory.sequence :name do |n|
  "Foo bar #{n}"
end
Factory.sequence :email do |n|
  "person#{n}@example.com"
end
Factory.sequence :uid do |n|
  "#{n}"
end
Factory.define :site do |f|
  f.name { Factory.next(:name) }
  f.title { Factory.next(:name) }
  f.path { Factory.next(:name) }
  f.host { Factory.next(:name) }
  f.gender "male"
  f.email { Factory.next(:email) }
  f.twitter "foobar"
  f.facebook "http://www.facebook.com/FooBar"
  f.blog "http://blog.foo.bar"
end
Factory.define :user do |f|
  f.provider "twitter"
  f.uid { Factory.next(:uid) }
  f.name "Foo bar"
  f.email { Factory.next(:email) }
  f.bio "This is Foo bar's biography."
  f.association :site, :factory => :site
end
Factory.define :category do |f|
  f.name { Factory.next(:name) }
end
Factory.define :project do |f|
  f.name "Foo bar"
  f.association :site, :factory => :site
  f.association :user, :factory => :user
  f.association :category, :factory => :category
  f.about "Foo bar"
  f.headline "Foo bar"
  f.goal 10000
  f.expires_at { 1.month.from_now }
  f.video_url 'http://vimeo.com/17298435'
end
Factory.define :reward do |f|
  f.association :project, :factory => :project
  f.minimum_value 1.00
  f.description "Foo bar"
end
Factory.define :backer do |f|
  f.association :project, :factory => :project
  f.association :user, :factory => :user
  f.association :site, :factory => :site
  f.confirmed true
  f.value 10.00
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
  f.association :site, :factory => :site
  f.name 'Foo Page'
  f.permalink 'foo_page'
  f.description 'foo description'
  f.logo File.open("#{Rails.root.to_s}/lib/fixtures/engage.png")
  f.video_url 'http://vimeo.com/28220980'
end
Factory.define :projects_site do |f|
  f.association :project, :factory => :project
  f.association :site, :factory => :site
end