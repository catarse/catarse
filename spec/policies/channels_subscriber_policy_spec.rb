require "spec_helper"

describe ChannelsSubscriberPolicy do
  subject{ ChannelsSubscriberPolicy }

  let(:subscription){ create(:channels_subscriber) }
  let(:user){ subscription.user }

  shared_examples_for "show permissions" do
    it "should deny access if user is nil" do
      should_not permit(nil, subscription)
    end

    it "should deny access if user is not updating his subscription" do
      should_not permit(User.new, subscription)
    end

    it "should permit access if user is subscription owner" do
      should permit(user, subscription)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      should permit(admin, subscription)
    end
  end

  permissions(:show?){ it_should_behave_like "show permissions" }

  permissions(:destroy?){ it_should_behave_like "show permissions" }
end
