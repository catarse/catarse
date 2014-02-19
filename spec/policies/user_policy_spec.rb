require "spec_helper"

describe UserPolicy do
  subject { UserPolicy }

  let(:user){ create(:user) }

  shared_examples_for "update permissions" do
    it "should deny access if user is nil" do
      should_not permit(nil, user)
    end

    it "should deny access if user is not updating himself" do
      should_not permit(User.new, user)
    end

    it "should permit access if user is project owner" do
      should permit(user, user)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      should permit(admin, user)
    end
  end

  permissions(:show?) do
    it{ should permit(nil, user) }
  end

  permissions(:update?){ it_should_behave_like "update permissions" }

  permissions(:credits?){ it_should_behave_like "update permissions" }

  permissions(:update_password?){ it_should_behave_like "update permissions" }

  permissions(:unsubscribe_notifications?){ it_should_behave_like "update permissions" }
end
