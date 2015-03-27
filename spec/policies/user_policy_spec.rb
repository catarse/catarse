require 'rails_helper'

RSpec.describe UserPolicy do
  subject { UserPolicy }

  let(:user){ create(:user) }

  shared_examples_for "update permissions" do
    it "should deny access if user is nil" do
      is_expected.not_to permit(nil, user)
    end

    it "should deny access if user is not updating himself" do
      is_expected.not_to permit(User.new, user)
    end

    it "should permit access if user is updating himself" do
      is_expected.to permit(user, user)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      is_expected.to permit(admin, user)
    end
  end

  permissions(:show?) do
    it{ is_expected.to permit(nil, user) }
  end

  permissions(:update?){ it_should_behave_like "update permissions" }

  permissions(:settings?){ it_should_behave_like "update permissions" }

  permissions(:billing?){ it_should_behave_like "update permissions" }

  permissions(:destroy?){ it_should_behave_like "update permissions" }

  permissions(:credits?){ it_should_behave_like "update permissions" }

  permissions(:unsubscribe_notifications?){ it_should_behave_like "update permissions" }
end
