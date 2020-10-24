FactoryBot.define do
  factory :notification do
    association :user
    template_name { 'project_invite' }
    user_email { 'person@email.com' }
    metadata do
      {
        associations: {
          project_id: 10
        },
        origin_name: 'Foo Bar',
        origin_email: 'foo@bar.com',
        locale: 'pt'
      }
    end
  end
end
