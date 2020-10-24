FactoryBot.define do
  factory :contribution do
    association :project
    association :user
    association :address
    value { 10.00 }
    payer_name { 'Foo Bar' }
    payer_email { 'foo@bar.com' }
    anonymous { false }

    factory :deleted_contribution do
      after :create do |contribution|
        create(:payment,
          state: 'deleted',
          value: contribution.value,
          contribution: contribution,
          created_at: contribution.created_at
        )
      end
    end

    factory :refused_contribution do
      after :create do |contribution|
        create(:payment,
          state: 'refused',
          value: contribution.value,
          contribution: contribution,
          created_at: contribution.created_at
        )
      end
    end

    factory :confirmed_contribution do
      after :create do |contribution|
        create(:payment,
          state: 'paid',
          gateway: 'Pagarme',
          value: contribution.value,
          contribution: contribution,
          created_at: contribution.created_at,
          payment_method: 'BoletoBancario')
      end
    end

    factory :pending_contribution do
      after :create do |contribution|
        create(:payment,
          state: 'pending',
          value: contribution.value,
          contribution: contribution,
          created_at: contribution.created_at
        )
      end
    end

    factory :pending_refund_contribution do
      after :create do |contribution|
        create(:payment,
          state: 'pending_refund',
          value: contribution.value,
          contribution: contribution,
          created_at: contribution.created_at
        )
      end
    end

    factory :refunded_contribution do
      after :create do |contribution|
        create(:payment,
          state: 'refunded',
          value: contribution.value,
          contribution: contribution,
          created_at: contribution.created_at)
      end
    end

    factory :contribution_with_credits do
      after :create do |contribution|
        create(:payment,
          state: 'paid',
          gateway: 'Credits',
          value: contribution.value,
          contribution: contribution)
      end
    end
  end
end
