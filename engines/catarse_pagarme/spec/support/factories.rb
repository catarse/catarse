# frozen_string_literal: true

FactoryGirl.define do
  sequence :name do |n|
    "Foo bar #{n}"
  end

  sequence :serial do |n|
    n
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

  factory :user do |f|
    f.name "Foo bar"
    f.public_name "Foo bar"
    f.cpf "111.111.111-11"
    f.email { generate(:email) }
  end

  factory :credi_card do |f|
    f.subscription_id { generate(:uid) }
    f.association :user, factory: :user
    f.last_digits '1235'
    f.card_brand 'visa'
  end

  factory :category do |f|
    f.name_pt { generate(:name) }
  end

  factory :bank do |f|
    f.name { generate(:uid) }
    f.code { generate(:serial) }
  end

  factory :balance_transfer do |f|
    f.association :user
    f.association :project
    f.amount 100
  end

  factory :balance_transaction do |f|
    f.association :user
    f.association :project
    f.amount 100
    f.event_name 'foo'
  end

  factory :bank_account do |f|
    f.association :bank
    f.account '25334'
    f.account_digit '2'
    f.agency '1432'
    f.agency_digit '2'
    f.owner_name 'Lorem amenori'
    f.owner_document '11111111111'
    f.account_type 'conta_corrente'
  end

  factory :project do |f|
    #after(:create) do |project|
    #  create(:reward, project: project)
    #  if project.state == 'change_to_online_after_create'
    #    project.update(state: 'online')
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
    f.online_days 5
    f.more_links 'Ipsum dolor'
    f.video_url 'http://vimeo.com/17298435'
    f.state 'online'
    f.budget '1000'
    f.uploaded_image File.open("#{Rails.root}/spec/support/testimg.png")
    after :create do |project|
      unless project.project_transitions.where(to_state: project.state).present?
        FactoryGirl.create(:project_transition, to_state: project.state, project: project)
      end

      # should set expires_at when create a project in these states
      if %w(online waiting_funds failed successful).include?(project.state) && project.online_days.present? && project.online_at.present?
        project.expires_at = (project.online_at + project.online_days.days).end_of_day
        project.save
      end
    end
    after :build do |project|
      project.account = build(:project_account, project: nil)
      project.rewards.build(deliver_at: 1.year.from_now, minimum_value: 10, description: 'test')
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
    f.to_state 'online'
    f.sort_key { generate(:serial) }
  end

  factory :project_transition do |f|
    f.association :project
    f.most_recent true
    f.to_state 'online'
    f.sort_key { generate(:serial) }
  end

  factory :project_account do |f|
    f.association :project
    f.association :bank
    f.account '25334'
    f.account_digit '2'
    f.agency '1432'
    f.agency_digit '2'
    f.owner_name 'Lorem amenori'
    f.owner_document '11111111111'
    f.email "foo@bar.com"
    f.address_zip_code "foo"
    f.address_neighbourhood "foo"
    f.address_state "foo"
    f.address_city "foo"
    f.address_number "foo"
    f.address_street "foo"
    f.phone_number "1234"
    f.account_type "foo"
  end

  factory :contribution do |f|
    f.association :project, factory: :project
    f.association :user, factory: :user
    # f.phone_number '(33) 3333-3333'
    f.address_neighbourhood 'lorem'
    f.address_number 'lnumber'
    f.address_street 'lstreet lorem'
    f.address_zip_code '33600-000'
    f.payer_document '872.123.775-11'
    f.value 10.00
    f.payer_name 'Foo Bar'
    f.payer_email 'foo@bar.com'
    f.anonymous false
    after :create do |contribution|
      create(:payment, paid_at: Time.now, gateway_id: '1.2.3', state: 'paid', value: contribution.value, contribution: contribution)
    end
  end

  factory :payment do |f|
    f.association :contribution
    f.gateway 'Pagarme'
    f.value 10.00
    f.state 'paid'
    f.installment_value nil
    f.payment_method "CartaoDeCredito"
    after :build do |payment|
      payment.gateway = 'Pagarme'
    end
  end

  factory :state do
    name { generate(:name) }
    acronym { generate(:name) }
  end

  factory :city do |f|
    f.association :state
    f.name "foo"
  end
end
