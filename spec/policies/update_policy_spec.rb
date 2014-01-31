require "spec_helper"

describe UpdatePolicy do
  subject{ UpdatePolicy }

  shared_examples_for "create permissions" do
    it "should deny access if user is nil" do
      should_not permit(nil, Update.new(project: create(:project)))
    end

    it "should deny access if user is not project owner" do
      should_not permit(User.new, Update.new(project: create(:project)))
    end

    it "should permit access if user is project owner" do
      new_user = create(:user)
      should permit(new_user, Update.new(project: create(:project, user: new_user)))
    end

    it "should permit access if user is admin" do
      admin = User.new
      admin.admin = true
      should permit(admin, Update.new(project: create(:project)))
    end
  end

  permissions :create? do
    it_should_behave_like "create permissions"
  end

  permissions :update? do
    it_should_behave_like "create permissions"
  end

  permissions :destroy? do
    it_should_behave_like "create permissions"
  end

  describe "#permitted?" do
    context "when user is nil" do
      let(:policy){ UpdatePolicy.new(nil, build(:update)) }
      [:title, :comment, :exclusive].each do |field|
        context "when field is #{field}" do
          subject{ policy.permitted?(field) }
          it{ should be_false }
        end
      end
    end
    context "when user is admin" do
      let(:user){ create(:user) }
      let(:update){ create(:update) }
      let(:policy){ UpdatePolicy.new(user, update) }

      before do
        user.admin = true
        user.save!
      end

      [:title, :comment, :exclusive].each do |field|
        context "when field is #{field}" do
          subject{ policy.permitted?(field.to_sym) }
          it{ should be_true }
        end
      end
    end
  end
end
