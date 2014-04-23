require "spec_helper"

describe AdminPolicy do
  let(:user) { nil }
  let(:channel) { nil }

  subject{ AdminPolicy.new(user, Admin, channel) }

  context "permission access?" do

    context "when user is nil" do
      it "should deny access if user is nil" do
        should_not custom_permit(:access?)
      end
    end

    context "whe user is not admin" do
      let(:user) { User.new }
      it "should deny access if user is not admin" do
        should_not custom_permit(:access?)
      end
    end

    context "when user is channel admin" do
      let(:user) { create(:user, channel: create(:channel))}
      let(:channel) { user.channel }

      it "should permit access if user is channel admin" do
        should custom_permit(:access?)
      end
    end

    context "when user is admin" do
      let(:user) {
        _user = User.new
        _user.admin = true
        _user
      }
      it "should permit access if user is admin" do
        should custom_permit(:access?)
      end
    end
  end
end

