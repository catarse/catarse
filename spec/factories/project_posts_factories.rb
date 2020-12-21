FactoryBot.define do
  factory :project_post do
    association :project
    association :user
    title { 'My title' }
    comment_html { '<p>This is a comment</p>' }
  end
end
