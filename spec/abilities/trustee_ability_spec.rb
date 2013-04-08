require 'spec_helper'
require "cancan/matchers"

describe Ability do

  describe ".trustee" do
    let(:ability) { Ability.new(user) }
    let(:user)    { nil }
    subject { ability }

    context "When the user is a trustee" do
      let(:user)      { FactoryGirl.create(:user) }
      let(:channel)   { FactoryGirl.create(:channel) }

      # Here we are making a little bit of magic:
      # The project from common doesn't belong to any channel,
      # but the project from channel does. So, the trustee
      # should have access to project from channel and not to project from common
      # He shouldn't be able to update or edit a project that doesn't 
      # belongs to channel he is not a trustee.
      let(:project_from_channel)  { FactoryGirl.create(:project) }
      let(:project_from_common)   { FactoryGirl.create(:project) }
      let(:reward_from_channel)   { FactoryGirl.create(:reward, project: project_from_channel) }
      let(:reward_from_common)    { FactoryGirl.create(:reward, project: project_from_common) }
      let(:other_user)            { FactoryGirl.create(:user) }

      before          { channel.trustees << user }
      before          { channel.projects << project_from_channel } 
   
      
      # He should be able to:
      # 1 - update a project from a channel
      # 2 - update a reward from a project within a channel
      # 3 - update himself
      it { should     be_able_to(:access, :all)     } 
      it { should     be_able_to(:update, project_from_channel) }
      it { should     be_able_to(:update, reward_from_channel) }
      it { should     be_able_to(:update, user) }

      # He should NOT be able to
      # 1 - update a project that doesn't belong to channel he is a trustee
      # 2 - update a reward from a project that doesn't belong to any channel he is a trustee
      # 3 - update others users
      it { should_not be_able_to(:update, project_from_common) }
      it { should_not be_able_to(:update, reward_from_common) }
      it { should_not be_able_to(:update, other_user) }

    end

  end


end
