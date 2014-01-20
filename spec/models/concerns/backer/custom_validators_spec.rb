require 'spec_helper'

describe Contribution::CustomValidators do
  let(:unfinished_project){ create(:project, state: 'online') }

  describe "#reward_must_be_from_project" do
    let(:contribution){ build(:contribution, reward: reward, project: unfinished_project) }
    subject{ contribution }
    context "when reward is from the same project" do
      let(:reward){ create(:reward, project: unfinished_project) }
      it{ should be_valid }
    end
    context "when reward is not from the same project" do
      let(:reward){ create(:reward) }
      it{ should_not be_valid }
    end
  end

  describe "#value_must_be_at_least_rewards_value" do
    let(:reward){ create(:reward, minimum_value: 500) }
    let(:contribution){ build(:contribution, reward: reward, project: reward.project, value: value) }
    subject{ contribution }
    context "when value is lower than reward minimum value" do
      let(:value){ 499.99 }
      it{ should_not be_valid }
    end
    context "when value is equal than reward minimum value" do
      let(:value){ 500.00 }
      it{ should be_valid }
    end
    context "when value is greater than reward minimum value" do
      let(:value){ 500.01 }
      it{ should be_valid }
    end
  end

  describe "#project_should_be_online" do
    subject{ contribution }
    context "when project is draft" do
      let(:contribution){ build(:contribution, project: create(:project, state: 'draft')) }
      it{ should_not be_valid }
    end
    context "when project is waiting_funds" do
      let(:contribution){ build(:contribution, project: create(:project, state: 'waiting_funds')) }
      it{ should_not be_valid }
    end
    context "when project is successful" do
      let(:contribution){ build(:contribution, project: create(:project, state: 'successful')) }
      it{ should_not be_valid }
    end
    context "when project is online" do
      let(:contribution){ build(:contribution, project: unfinished_project) }
      it{ should be_valid }
    end
    context "when project is failed" do
      let(:contribution){ build(:contribution, project: create(:project, state: 'failed')) }
      it{ should_not be_valid }
    end
  end

  describe "#should_not_back_if_maximum_contributions_been_reached" do
    let(:reward){ create(:reward, maximum_contributions: 1) }
    let(:contribution){ build(:contribution, reward: reward, project: reward.project) }
    subject{ contribution }

    context "when contributions count is lower than maximum_contributions" do
      it{ should be_valid }
    end

    context "when pending contributions count is equal than maximum_contributions" do
      before{ create(:contribution, reward: reward, project: reward.project, state: 'waiting_confirmation') }
      it{ should_not be_valid }
    end

    context "when contributions count is equal than maximum_contributions" do
      before{ create(:contribution, reward: reward, project: reward.project, state: 'confirmed') }
      it{ should_not be_valid }
    end
  end


end
