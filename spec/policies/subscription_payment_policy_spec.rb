# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionPaymentPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:subscription_payment) do
    SubscriptionPayment.new(
      id: SecureRandom.uuid,
      project: create(:subscription_project, user: user),
      user: user,
      gateway_cached_data: {
        payables: {
          amount: Faker::Number.number(digits: 4),
          id: Faker::Number.number(digits: 4),
          payment_date: Time.zone.now,
          payment_method: 'boleto'
        }
      }
    )
  end

  shared_examples_for 'create permissions' do
    it 'denies access if user is nil' do
      expect(subject).not_to permit(nil, subscription_payment)
    end

    it 'denies access if user is not project owner' do
      expect(subject).not_to permit(User.new, subscription_payment)
    end

    it 'permits access if user is project owner' do
      expect(subject).to permit(user, subscription_payment)
    end

    it 'permits access if user is admin' do
      admin = build(:user, admin: true)
      expect(subject).to permit(admin, subscription_payment)
    end
  end

  permissions(:receipt?) { it_behaves_like 'create permissions' }
end
