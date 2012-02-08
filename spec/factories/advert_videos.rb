# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :advert_video do
    title "MyString"
    description "MyText"
    video_url "MyString"
    visible false
  end
end
