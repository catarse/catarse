require "spec_helper"

describe ContributionPolicy do
  subject{ ContributionPolicy }

  let(:contribution){ create(:contribution) }
  let(:user){ contribution.user }

  shared_examples_for "update permissions" do
    it "should deny access if user is nil" do
      should_not permit(nil, contribution)
    end

    it "should deny access if user is not updating his contribution" do
      should_not permit(User.new, contribution)
    end

    it "should permit access if user is contribution owner" do
      should permit(user, contribution)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      should permit(admin, contribution)
    end
  end

  permissions(:show?){ it_should_behave_like "update permissions" }

  permissions(:update?){ it_should_behave_like "update permissions" }

  permissions(:edit?){ it_should_behave_like "update permissions" }

  permissions(:credits_checkout?){ it_should_behave_like "update permissions" }

  permissions(:request_refund?){ it_should_behave_like "update permissions" }
end
