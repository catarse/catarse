require 'rails_helper'

RSpec.describe RewardPolicy do
  subject{ RewardPolicy }

  let(:policy){ RewardPolicy.new(user, reward) }
  let(:user){ nil }
  let(:reward){ create(:reward) }

  shared_examples_for "create permissions" do
    it "should deny access if user is nil" do
      is_expected.not_to permit(nil, reward)
    end

    it "should deny access if user is not project owner" do
      is_expected.not_to permit(User.new, reward)
    end

    it "should permit access if user is project owner" do
      new_user = reward.project.user
      is_expected.to permit(new_user, reward)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      is_expected.to permit(admin, reward)
    end
  end

  shared_examples_for "destroy permissions" do
    it_should_behave_like "create permissions"

    it "should deny access if reward has one contribution waiting for confirmation" do
      create(:pending_contribution, project: reward.project, reward: reward)
      is_expected.not_to permit(reward.project.user, reward)
    end

    it "should deny access if reward has one confirmed contribution" do
      create(:confirmed_contribution, project: reward.project, reward: reward)
      is_expected.not_to permit(reward.project.user, reward)
    end
  end


  permissions :new? do
    it_should_behave_like "create permissions"
  end

  permissions :create? do
    it_should_behave_like "create permissions"
  end

  permissions :edit? do
    it_should_behave_like "create permissions"
  end

  permissions :update? do
    it_should_behave_like "create permissions"
  end

  permissions :sort? do
    it_should_behave_like "create permissions"
  end

  permissions :destroy? do
    it_should_behave_like "destroy permissions"
  end

  describe "#permitted_for?" do
    let(:user){ reward.project.user }
    subject{ policy.permitted_for?(field, :update) }

    [:pending_contribution, :confirmed_contribution].each do |state|
      context "when we have one contribution in state #{state}" do
        before do
          create(state, project: reward.project, reward: reward)
        end

        context "and want to update minimum_value" do
          let(:field){ :minimum_value }
          it{ is_expected.to eq(false) }
        end

        context "and want to update description" do
          let(:field){ :description }
          it{ is_expected.to eq(true) }
        end

        context "and want to update maximum_contributions" do
          let(:field){ :maximum_contributions }
          it{ is_expected.to eq(true) }
        end

        context "and want to update deliver_at" do
          let(:field){ :deliver_at}
          it{ is_expected.to eq(true) }
        end
      end
    end

    ['failed', 'successful'].each do |state|
      context "when reward's project is in state #{state}" do
        let(:reward){ create(:reward, project: create(:project, state: state)) }
        context "and want to update minimum_value" do
          let(:field){ :minimum_value }
          it{ is_expected.to eq(true) }
        end

        context "and want to update description" do
          let(:field){ :description }
          it{ is_expected.to eq(true) }
        end

        context "and want to update maximum_contributions" do
          let(:field){ :maximum_contributions }
          it{ is_expected.to eq(true) }
        end

        context "and want to update deliver_at" do
          let(:field){ :deliver_at}
          it{ is_expected.to eq(false) }
        end
      end
    end

    context "when reward's project is in state online" do
      let(:reward){ create(:reward, project: create(:project, state: 'online')) }
      context "and want to update minimum_value" do
        let(:field){ :minimum_value }
        it{ is_expected.to eq(true) }
      end

      context "and want to update description" do
        let(:field){ :description }
        it{ is_expected.to eq(true) }
      end

      context "and want to update maximum_contributions" do
        let(:field){ :maximum_contributions }
        it{ is_expected.to eq(true) }
      end

      context "and want to update deliver_at" do
        let(:field){ :deliver_at }
        it{ is_expected.to eq(true) }
      end
    end
  end
end

