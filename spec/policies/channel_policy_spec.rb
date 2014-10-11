require 'rails_helper'

RSpec.describe ChannelPolicy do
  subject{ ChannelPolicy }

  let(:channel){ create(:channel) }
  let(:user){ create(:user, channel: channel) }

  shared_examples_for "update permissions" do
    it "should deny access if user is nil" do
      is_expected.not_to permit(nil, channel)
    end

    it "should deny access if user is not updating his channel" do
      is_expected.not_to permit(User.new, channel)
    end

    it "should permit access if user is channel manager" do
      is_expected.to permit(user, channel)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      is_expected.to permit(admin, channel)
    end
  end

  permissions(:update?){ it_should_behave_like "update permissions" }

  permissions(:edit?){ it_should_behave_like "update permissions" }
end

