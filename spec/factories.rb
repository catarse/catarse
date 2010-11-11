Factory.sequence :email do |n|
  "person#{n}@example.com"
end

Factory.define :user do |u|
  u.name "Foo bar"
  u.email Factory.next(:email)
  u.password "foobar123"
  u.password_confirmation "foobar123"
end

