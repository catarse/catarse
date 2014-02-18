require "spec_helper"

describe ChannelPolicy do
  subject{ ChannelPolicy }

  let(:channel){ create(:channel) }
  let(:user){ create(:user, channel: channel) }

  shared_examples_for "update permissions" do
    it "should deny access if user is nil" do
      should_not permit(nil, channel)
    end

    it "should deny access if user is not updating his channel" do
      should_not permit(User.new, channel)
    end

    it "should permit access if user is channel manager" do
      should permit(user, channel)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      should permit(admin, channel)
    end
  end

  permissions(:update?){ it_should_behave_like "update permissions" }

  permissions(:edit?){ it_should_behave_like "update permissions" }
end

