require 'rails_helper'

RSpec.describe ContributionPolicy do
  subject{ ContributionPolicy }

  let(:project){ create(:project) }
  let(:contribution){ create(:contribution) }
  let(:user){ contribution.user }

  shared_examples_for "update permissions" do
    it "should deny access if user is nil" do
      is_expected.not_to permit(nil, contribution)
    end

    it "should deny access if user is not updating his contribution" do
      is_expected.not_to permit(User.new, contribution)
    end

    it "should permit access if user is contribution owner" do
      is_expected.to permit(user, contribution)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      is_expected.to permit(admin, contribution)
    end
  end

  shared_examples_for "create permissions" do
    it_should_behave_like "update permissions"

    ['draft', 'deleted', 'rejected', 'successful', 'failed', 'waiting_funds', 'in_analysis'].each do |state|
      it "should deny access if project is #{state}" do
        contribution.project.update_attributes state: state
        is_expected.not_to permit(user, contribution)
      end
    end
  end

  permissions(:new?){
    ['draft', 'deleted', 'rejected', 'successful', 'failed', 'waiting_funds', 'in_analysis'].each do |state|
      it "should deny access if project is #{state}" do
        contribution.project.update_attributes state: state
      end
    end
  }

  permissions(:create?){ it_should_behave_like "create permissions" }

  permissions(:show?){ it_should_behave_like "update permissions" }

  permissions(:update?){ it_should_behave_like "update permissions" }

  permissions(:edit?){ it_should_behave_like "update permissions" }

  permissions(:credits_checkout?){ it_should_behave_like "update permissions" }

  permissions(:request_refund?){ it_should_behave_like "update permissions" }

  describe 'UserScope' do
    describe ".resolve" do
      let(:current_user) { create(:user, admin: false) }
      let(:user) { nil }
      before do
        create(:pending_contribution, project: project)
        @contribution = create(:confirmed_contribution, anonymous: false, project: project)
        @anon_contribution = create(:confirmed_contribution, anonymous: true, project: project)
      end

      subject { ContributionPolicy::UserScope.new(current_user, user, project.contributions).resolve.order('created_at desc') }

      context "when user is admin" do
        let(:current_user) { create(:user, admin: true) }

        it { is_expected.to have(3).itens }
      end

      context "when user is a contributor" do
        let(:current_user) { user }
        it { is_expected.to eq [@anon_contribution, @contribution] }
      end

      context "when user is not an admin" do
        it { is_expected.to eq [@contribution] }
      end
    end
  end

  describe "#permitted?" do
    let(:policy){ ContributionPolicy.new(user, build(:contribution)) }
    subject{ policy }

    %i[user_attributes user_id user payment_service_fee payment_id].each do |field|
      it{ is_expected.not_to be_permitted(field) }
    end

    %i[value].each do |field|
      it{ is_expected.to be_permitted(field) }
    end
  end

end
