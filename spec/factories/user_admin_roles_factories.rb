FactoryBot.define do
  factory :user_admin_role do
    association :user
    role_label { 'balance' }
  end
end
