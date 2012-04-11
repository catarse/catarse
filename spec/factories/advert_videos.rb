# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :advert_video do
    title "My title"
    description "Some Description"
    video_url "http://vimeo.com/35492726"
    visible false
  end
end
