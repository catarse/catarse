Factory.sequence :email do |n|
  "person#{n}@example.com"
end

Factory.define :user do |f|
  f.name "Foo bar"
  f.email Factory.next(:email)
  f.password "foobar123"
  f.password_confirmation "foobar123"
end

Factory.define :category do |f|
  f.name "Foo bar"
end

Factory.define :project do |f|
  f.name "Foo bar"
  f.association :user, :factory => :user
  f.association :category, :factory => :category
end

