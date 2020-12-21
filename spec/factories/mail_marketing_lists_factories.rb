FactoryBot.define do
  factory :mail_marketing_list do
    provider { 'sendgrid' }
    sequence :label do |n|
      "label_#{n}"
    end
    sequence :list_id do |n|
      "list_#{n}"
    end
  end
end
