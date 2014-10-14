require 'rails_helper'

RSpec.describe ChannelsSubscriberPolicy do
  subject{ ChannelsSubscriberPolicy }

  let(:subscription){ create(:channels_subscriber) }
  let(:user){ subscription.user }

  shared_examples_for "show permissions" do
    it "should deny access if user is nil" do
      is_expected.not_to permit(nil, subscription)
    end

    it "should deny access if user is not updating his subscription" do
      is_expected.not_to permit(User.new, subscription)
    end

    it "should permit access if user is subscription owner" do
      is_expected.to permit(user, subscription)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      is_expected.to permit(admin, subscription)
    end
  end

  permissions(:show?){ it_should_behave_like "show permissions" }

  permissions(:destroy?){ it_should_behave_like "show permissions" }
end
