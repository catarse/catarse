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
Factory.define :payment_detail do |f|
  f.association :backer
  f.payer_name { Factory.next(:name) }
  f.payer_email { Factory.next(:email) }
  f.city 'Lorem'
  f.uf 'IP'
  f.payment_method 'BoletoBancario'
  f.net_amount 979.63
  f.total_amount 999
  f.service_tax_amount 19.37
  f.payment_status 'BoletoImpresso'
  f.service_code '000.0000123'
  f.institution_of_payment 'Itau'
  f.payment_date "2011-09-30T09:33:37.000-03:00".to_datetime
end
Factory.define :backer do |f|
  f.association :project, :factory => :project
  f.association :user, :factory => :user
  f.payment_detail nil
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
  f.name 'Foo Page'
  f.permalink 'foo_page'
  f.description 'foo description'
  f.logo File.open("#{Rails.root.to_s}/lib/fixtures/engage.png")
  f.video_url 'http://vimeo.com/28220980'
end
Factory.define :projects_curated_page do |f|
  f.association :project, :factory => :project
  f.association :curated_page, :factory => :curated_page
end
