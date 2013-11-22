require 'spec_helper'

describe Backer::CustomValidators do
  let(:unfinished_project){ create(:project, state: 'online') }

  describe "#reward_must_be_from_project" do
    let(:backer){ build(:backer, reward: reward, project: unfinished_project) }
    subject{ backer }
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
    let(:backer){ build(:backer, reward: reward, project: reward.project, value: value) }
    subject{ backer }
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
    subject{ backer }
    context "when project is draft" do
      let(:backer){ build(:backer, project: create(:project, state: 'draft')) }
      it{ should_not be_valid }
    end
    context "when project is waiting_funds" do
      let(:backer){ build(:backer, project: create(:project, state: 'waiting_funds')) }
      it{ should_not be_valid }
    end
    context "when project is successful" do
      let(:backer){ build(:backer, project: create(:project, state: 'successful')) }
      it{ should_not be_valid }
    end
    context "when project is online" do
      let(:backer){ build(:backer, project: unfinished_project) }
      it{ should be_valid }
    end
    context "when project is failed" do
      let(:backer){ build(:backer, project: create(:project, state: 'failed')) }
      it{ should_not be_valid }
    end
  end

  describe "#should_not_back_if_maximum_backers_been_reached" do
    let(:reward){ create(:reward, maximum_backers: 1) }
    let(:backer){ build(:backer, reward: reward, project: reward.project) }
    subject{ backer }

    context "when backers count is lower than maximum_backers" do
      it{ should be_valid }
    end

    context "when pending backers count is equal than maximum_backers" do
      before{ create(:backer, reward: reward, project: reward.project, state: 'waiting_confirmation') }
      it{ should_not be_valid }
    end

    context "when backers count is equal than maximum_backers" do
      before{ create(:backer, reward: reward, project: reward.project, state: 'confirmed') }
      it{ should_not be_valid }
    end
  end


end
