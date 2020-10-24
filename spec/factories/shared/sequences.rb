FactoryBot.define do
  sequence :name do |n|
    "Foo bar #{n}"
  end

  sequence :bank_number do |n|
    n.to_s.rjust(3, '0')
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :uid do |n|
    n.to_s
  end

  sequence :serial do |n|
    n
  end

  sequence :permalink do |n|
    "foo_page_#{n}"
  end

  sequence :domain do |n|
    "foo#{n}lorem.com"
  end
end
