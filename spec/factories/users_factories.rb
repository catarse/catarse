FactoryBot.define do
  factory :user do
    bank_account { nil }
    association :address
    permalink { generate(:permalink) }
    name { 'Foo bar' }
    public_name { 'Public bar' }
    password { '123456' }
    cpf { '97666238991' }
    uploaded_image { File.open('spec/fixtures/files/testimg.png') }
    email { generate(:email) }
    about_html { 'This is Foo bar biography.' }
    birth_date { '10/10/1989' }
    full_text_index { {} }

    trait :with_bank_account do
      after :create do |user|
        user.bank_account = create(:bank_account, user: user)
      end
    end
  end

  factory :blacklisted_user, class: 'User' do
    association :address
    permalink { generate(:permalink) }
    name { 'Foo bar' }
    public_name { 'Public bar' }
    password { '123456' }
    cpf { '64118189402' }
    email { generate(:email) }

    trait :with_bank_account do
      after :create do |user|
        user.bank_account = create(:bank_account, user: user)
      end
    end
  end
end
