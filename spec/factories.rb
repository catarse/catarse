Factory.sequence :name do |n|
  "Foo bar #{n}"
end
Factory.sequence :email do |n|
  "person#{n}@example.com"
end
Factory.sequence :uid do |n|
  "#{n}"
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
  f.association :user, :factory => :user
  f.association :category, :factory => :category
  f.about "Foo bar"
  f.goal 10000
  f.deadline { 1.month.from_now }
  f.video_url 'http://vimeo.com/17298435'
end
Factory.define :reward do |f|
  f.association :project, :factory => :project
  f.minimum_value 1.00
  f.maximum_backers 0
  f.description "Foo bar"
end
Factory.define :backer do |f|
  f.association :project, :factory => :project
  f.association :user, :factory => :user
  f.value 1.00
end
