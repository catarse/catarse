require "spec_helper"

describe AdminPolicy do
  subject{ AdminPolicy }

  permissions :access? do
    it "should deny access if user is nil" do
      should_not permit(nil, Admin)
    end

    it "should deny access if user is not admin" do
      should_not permit(User.new, Admin)
    end

    it "should permit access if user is channel admin" do
      channel_admin = create(:user, channel: create(:channel))
      should permit(channel_admin, Admin)
    end

    it "should permit access if user is admin" do
      admin = User.new
      admin.admin = true
      should permit(admin, Admin)
    end
  end
end

