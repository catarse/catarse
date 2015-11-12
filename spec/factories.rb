FactoryGirl.define do
  sequence :name do |n|
    "Foo bar #{n}"
  end

  sequence :bank_number do |n|
    "0000#{n}"
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :uid do |n|
    "#{n}"
  end

  sequence :permalink do |n|
    "foo_page_#{n}"
  end

  factory :category_follower do |f|
    f.association :user
    f.association :category
  end

  factory :country do |f|
    f.name "Brasil"
  end

  factory :user do |f|
    f.association :bank_account
    f.permalink { generate(:permalink) }
    f.name "Foo bar"
    f.password "123456"
    f.cpf "97666238991"
    f.uploaded_image File.open("#{Rails.root}/spec/support/testimg.png")
    f.email { generate(:email) }
    f.about_html "This is Foo bar's biography."
    f.association :country, factory: :country
    f.address_street 'fooo'
    f.address_number '123'
    f.address_city 'fooo bar'
    f.address_state 'fooo'
    f.address_neighbourhood 'bar'
    f.address_zip_code '123344333'
    f.phone_number '1233443355'

    trait :without_bank_data do
      bank_account { nil }
    end
  end

  factory :category do |f|
    f.name_pt { generate(:name) }
  end

  factory :project do |f|
    #after(:create) do |project|
    #  create(:reward, project: project)
    #  if project.state == 'change_to_online_after_create'
    #    project.update_attributes(state: 'online')
    #  end
    #end
    f.name "Foo bar"
    f.permalink { generate(:permalink) }
    f.association :user
    f.association :category
    f.association :city
    f.about_html "Foo bar"
    f.headline "Foo bar"
    f.goal 10000
    f.online_date Time.now
    f.online_days 5
    f.more_links 'Ipsum dolor'
    f.first_contributions 'Foo bar'
    f.video_url 'http://vimeo.com/17298435'
    f.state 'online'
    f.budget '1000'
    f.uploaded_image File.open("#{Rails.root}/spec/support/testimg.png")
    after :create do |project| 
      FactoryGirl.create(:project_transition, to_state: project.state, project: project)
    end
    after :build do |project|
      project.account = build(:project_account, project: nil)
      project.rewards.build(deliver_at: Time.now, minimum_value: 10, description: 'test')
    end
  end

  factory :flexible_project do |f|
    f.association :project
    f.state 'draft'

    after :create do |flex_project| 
      FactoryGirl.create(:flexible_project_transition, {
        to_state: flex_project.state,
        flexible_project: flex_project
      })
    end
  end

  factory :flexible_project_transition do |f|
    f.association :flexible_project
    f.most_recent true
    f.sort_key 1
  end

  factory :project_transition do |f|
    f.association :project
    f.most_recent true
    f.sort_key 1
  end

  factory :project_account do |f|
    f.association :project
    f.association :bank
    f.email "foo@bar.com"
    f.address_zip_code "foo"
    f.address_neighbourhood "foo"
    f.address_state "foo"
    f.address_city "foo"
    f.address_number "foo"
    f.address_street "foo"
    f.phone_number "1234"
    f.agency "fooo"
    f.agency_digit "foo"
    f.owner_document "foo"
    f.owner_name "foo"
    f.account "1"
    f.account_digit "1000"
    f.account_type "foo"
  end

  factory :user_link do |f|
    f.association :user
    f.link "http://www.foo.com"
  end

  factory :project_budget do |f|
    f.association :project
    f.name "Foo Bar"
    f.value "10"
  end

  factory :unsubscribe do |f|
    f.association :user, factory: :user
    f.association :project, factory: :project
  end

  factory :notification do |f|
    f.association :user, factory: :user
    f.association :contribution, factory: :contribution
    f.association :project, factory: :project
    f.template_name 'project_success'
    f.origin_name 'Foo Bar'
    f.origin_email 'foo@bar.com'
    f.locale 'pt'
  end

  factory :reward do |f|
    f.association :project, factory: :project
    f.minimum_value 10.00
    f.description "Foo bar"
    f.deliver_at 10.days.from_now
  end

  factory :rewards, class: Reward do |f|
    f.minimum_value 10.00
    f.description "Foo bar"
    f.deliver_at 10.days.from_now
  end


  factory :contribution do |f|
    f.association :project, factory: :project
    f.association :user, factory: :user
    f.value 10.00
    f.payer_name 'Foo Bar'
    f.payer_email 'foo@bar.com'
    f.anonymous false
    factory :deleted_contribution do
      after :create do |contribution|
        create(:payment, state: 'deleted', value: contribution.value, contribution: contribution, created_at: contribution.created_at)
      end
    end
    factory :refused_contribution do
      after :create do |contribution|
        create(:payment, state: 'refused', value: contribution.value, contribution: contribution, created_at: contribution.created_at)
      end
    end
    factory :confirmed_contribution do
      after :create do |contribution|
        create(:payment, state: 'paid', gateway: 'Pagarme', value: contribution.value, contribution: contribution, created_at: contribution.created_at, payment_method: 'BoletoBancario')
      end
    end
    factory :pending_contribution do
      after :create do |contribution|
        create(:payment, state: 'pending', value: contribution.value, contribution: contribution, created_at: contribution.created_at)
      end
    end
    factory :pending_refund_contribution do
      after :create do |contribution|
        create(:payment, state: 'pending_refund', value: contribution.value, contribution: contribution, created_at: contribution.created_at)
      end
    end
    factory :refunded_contribution do
      after :create do |contribution|
        create(:payment, state: 'refunded', value: contribution.value, contribution: contribution, created_at: contribution.created_at)
      end
    end
    factory :contribution_with_credits do
      after :create do |contribution|
        create(:payment, state: 'paid', gateway: 'Credits', value: contribution.value, contribution: contribution)
      end
    end
  end

  factory :payment do |f|
    f.association :contribution
    f.gateway 'Pagarme'
    f.value 10.00
    f.installment_value 10.00
    f.payment_method "CartaoDeCredito"
  end

  factory :payment_notification do |f|
    f.association :contribution, factory: :contribution
    f.extra_data {}
  end

  factory :credit_card do |f|
    f.association :user
    f.last_digits '1234'
    f.card_brand 'Foo'
  end

  factory :authorization do |f|
    f.association :oauth_provider
    f.association :user
    f.uid 'Foo'
  end

  factory :oauth_provider do |f|
    f.name 'facebook'
    f.strategy 'GitHub'
    f.path 'github'
    f.key 'test_key'
    f.secret 'test_secret'
  end

  factory :configuration do |f|
    f.name 'Foo'
    f.value 'Bar'
  end

  factory :institutional_video do |f|
    f.title "My title"
    f.description "Some Description"
    f.video_url "http://vimeo.com/35492726"
    f.visible false
  end

  factory :project_post do |f|
    f.association :project, factory: :project
    f.association :user, factory: :user
    f.title "My title"
    f.comment_html "<p>This is a comment</p>"
  end

  factory :state do
    name { generate(:name) }
    acronym { generate(:name) }
  end

  factory :city do |f|
    f.association :state
    f.name "foo"
  end

  factory :bank do
    name "Foo"
    code { generate(:bank_number) }
  end

  factory :bank_account do |f|
    #f.association :user, factory: :user
    f.association :bank, factory: :bank
    input_bank_number nil
    owner_name "Foo Bar"
    owner_document "97666238991"
    account_digit "1"
    agency "1234"
    agency_digit "1"
    account "1"
  end

  factory :single_bank_account, class: BankAccount do |f|
    f.association :bank, factory: :bank
    owner_name "Foo"
    owner_document "000"
    account_digit "1"
    agency "1234"
    account '1'
  end

end
