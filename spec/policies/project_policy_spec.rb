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

  describe "#permitted_for?" do
    context "when user is nil and I want to update about" do
      let(:policy){ ProjectPolicy.new(nil, Project.new) }
      subject{ policy.permitted_for?(:about, :update) }
      it{ should be_false }
    end

    context "when user is project owner and I want to update about" do
      let(:project){ create(:project) }
      let(:policy){ ProjectPolicy.new(project.user, project) }
      subject{ policy.permitted_for?(:about, :update) }
      it{ should be_true }
    end
  end

  describe "#permitted?" do
    context "when user is nil" do
      let(:policy){ ProjectPolicy.new(nil, Project.new) }
      [:about, :video_url, :uploaded_image, :headline].each do |field|
        context "when field is #{field}" do
          subject{ policy.permitted?(field) }
          it{ should be_true }
        end
      end
      context "when field is title" do
        subject{ policy.permitted?(:title) }
        it{ should be_false }
      end
    end
    context "when user is admin" do
      let(:user){ create(:user) }
      let(:project){ create(:project) }
      let(:policy){ ProjectPolicy.new(user, project) }

      before do
        user.admin = true
        user.save!
      end

      Project.attribute_names.each do |field|
        context "when field is #{field}" do
          subject{ policy.permitted?(field.to_sym) }
          it{ should be_true }
        end
      end
    end
  end

end
