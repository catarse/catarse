require "spec_helper"

describe ProjectPolicy do
  subject{ ProjectPolicy }

  shared_examples_for "create permissions" do
    it "should deny access if user is nil" do
      should_not permit(nil, Project.new)
    end

    it "should deny access if user is not project owner" do
      should_not permit(User.new, Project.new(user: User.new))
    end

    it "should permit access if user is project owner" do
      new_user = User.new
      should permit(new_user, Project.new(user: new_user))
    end

    it "should permit access if user is admin" do
      admin = User.new
      admin.admin = true
      should permit(admin, Project.new(user: User.new))
    end
  end

  permissions :create? do
    it_should_behave_like "create permissions"
  end


  permissions :update? do
    it_should_behave_like "create permissions"
  end

  permissions :send_to_analysis? do
    it_should_behave_like "create permissions"
  end

end
