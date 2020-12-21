FactoryBot.define do
  factory :address do
    association :country, factory: :country
    association :state, factory: :state
    address_street { 'fooo' }
    address_number { '123' }
    address_city { 'fooo bar' }
    address_neighbourhood { 'bar' }
    address_zip_code { '123344333' }
    phone_number { '1233443355' }
  end
end
