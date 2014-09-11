require "spec_helper"

describe ProjectPostPolicy do
  subject { ProjectPostPolicy }

  shared_examples_for "create permissions" do
    it "should deny access if user is nil" do
      should_not permit(nil, ProjectPost.new(project: create(:project)))
    end

    it "should deny access if user is not project owner" do
      should_not permit(User.new, ProjectPost.new(project: create(:project)))
    end

    it "should permit access if user is project owner" do
      new_user = create(:user)
      should permit(new_user, ProjectPost.new(project: create(:project, user: new_user)))
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      should permit(admin, ProjectPost.new(project: create(:project)))
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
      let(:policy){ ProjectPostPolicy.new(nil, build(:project_post)) }
      subject{ policy }

      %i[title comment exclusive].each do |field|
        it{ should_not be_permitted(field) }
      end
    end
    context "when user is admin" do
      let(:user){ create(:user) }
      let(:project_post){ create(:project_post) }
      let(:policy){ ProjectPostPolicy.new(user, project_post) }

      subject{ policy }

      before do
        user.admin = true
        user.save!
      end

      %i[title comment exclusive].each do |field|
        it{ should be_permitted(field) }
      end
    end
  end

  describe ".show?" do
    let(:project) { create(:project) }
    let(:user) { }

    context "when post is exclusive" do
      let(:project_post){ create(:project_post, project: project, exclusive: true) }
      let(:policy){ ProjectPostPolicy.new(user, project_post).show? }
      subject{ policy }

      context "when user is a contributor" do
        let(:user) { create(:contribution, state: 'confirmed', project: project).user }
        it { should eq true }
      end

      context "when user is not a contributor" do
        let(:user) { create(:contribution, state: 'pending', project: project).user }

        it { should eq false }
      end

      context "when user is a project owner" do
        let(:user) { project.user }

        it { should eq true }
      end

      context "when user is an admin" do
        let(:user) { create(:user, admin: true) }

        it { should eq true }
      end

      context "when user is a guest" do
        it { should be nil }
      end
    end

    context "when post is not exclusive" do
      let(:project_post){ create(:project_post, project: project, exclusive: false) }
      let(:policy){ ProjectPostPolicy.new(user, project_post).show? }
      subject{ policy }

      context "when user is a guest" do
        it { should be true }
      end

    end
  end

end
