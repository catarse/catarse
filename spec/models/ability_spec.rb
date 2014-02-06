require 'spec_helper'
require "cancan/matchers"

describe Ability do
  subject { Ability.new(user) }

  context "When user is admin" do
    let(:user) { FactoryGirl.create(:user, admin: true) }

    it { should be_able_to(:access, :all) }
  end

  context "When user is project owner" do
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project, user: user) }
    let(:reward) { FactoryGirl.create(:reward, project: project) }

    it { should_not be_able_to(:access, :all) }
    it { should be_able_to(:update, project) }

    describe "when project is approved" do
      before { project.approve }

      it { should_not be_able_to(:update, project, :name) }
      it { should_not be_able_to(:update, project, :goal) }
      it { should_not be_able_to(:update, project, :online_days) }
      it { should be_able_to(:update, project, :about) }
      it { should be_able_to(:update, project, :video_url) }
      it { should be_able_to(:update, project, :headline) }
      it { should be_able_to(:update, project, :uploaded_image) }

    end

    describe 'When project is waiting funds' do
      let(:project) { FactoryGirl.create(:project, user: user, state: 'waiting_funds') }

      it { should be_able_to(:update, project, :video_url) }
      it { should be_able_to(:update, project, :uploaded_image) }
      it { should be_able_to(:update, project, :about) }
      it { should be_able_to(:update, project, :headline) }
    end

    describe "when project is failed" do
      let(:project) { FactoryGirl.create(:project, user: user, state: 'failed') }

      it { should be_able_to(:update, project, :video_url) }
      it { should be_able_to(:update, project, :uploaded_image) }
      it { should be_able_to(:update, project, :about) }
      it { should be_able_to(:update, project, :headline) }
    end

    describe "when project is successful" do
      let(:project) { FactoryGirl.create(:project, user: user, state: 'successful') }

      it { should be_able_to(:update, project, :video_url) }
      it { should be_able_to(:update, project, :uploaded_image) }
      it { should be_able_to(:update, project, :about) }
      it { should be_able_to(:update, project, :headline) }
    end
  end

  context "When is regular user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project) }
    let(:reward) { FactoryGirl.create(:reward, project: project) }

    it { should_not be_able_to(:access, :all) }
    it { should_not be_able_to(:update, project) }
  end

  context "When is a guest" do
    let(:user) { nil }
    let(:project) { FactoryGirl.create(:project) }
    let(:reward) { FactoryGirl.create(:reward, project: project) }

    it { should_not be_able_to(:access, :all) }
    it { should_not be_able_to(:update, project) }
    it { should_not be_able_to(:create, :projects) }
  end
end
