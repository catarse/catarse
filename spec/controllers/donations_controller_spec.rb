require 'rails_helper'


RSpec.describe DonationsController, type: :controller do
  subject{ response }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "POST create" do
    let!(:project) {create(:project, state: 'failed')}
    before do
      allow_any_instance_of(User).to receive(:credits).and_return(10)
      project.contributions = contributions
      project.save(validate: false)
      post :create
    end

    context "when user is not logged in" do
      let(:user){ nil }
      let(:contributions) { [] }
      it{ is_expected.to redirect_to new_user_registration_path }

    end

    context "when user is logged in with pagarme and legacy refunds" do
      let(:user){ create(:user) }
      let(:contributions) { (1..2).map{ create(:confirmed_contribution, user: user) }}

      it{ is_expected.to be_success }

      it 'should create donation for legacy and pagarme' do
        expect(Donation.count).to eq 2
      end

      it 'should create notification' do
        expect(DonationNotification.count).to eq 1
      end

      it 'should update pending refunds' do
        expect(project.payments.where(state: 'refunded').count).to eq 2
      end

      it 'set contribution donation' do
        expect(project.contributions.where.not(donation: nil).count).to eq 2
      end

    end

  end

end


