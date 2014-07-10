require "spec_helper"

describe UpdatePolicy do
  subject { UpdatePolicy }

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
      admin = build(:user, admin: true)
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
      subject{ policy }

      %i[title comment exclusive].each do |field|
        it{ should_not be_permitted(field) }
      end
    end
    context "when user is admin" do
      let(:user){ create(:user) }
      let(:update){ create(:update) }
      let(:policy){ UpdatePolicy.new(user, update) }

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

  describe 'Scope' do
    describe ".resolve" do
      let(:project) { create(:project) }
      let(:user) {}

      before do
        @exclusive_update = create(:update, exclusive: true, project: project)
        @update = create(:update, project: project)
      end

      subject { UpdatePolicy::Scope.new(user, project.updates).resolve }

      context "when user is a contributor" do
        let(:user) { create(:contribution, state: 'confirmed', project: project).user }

        it { should have(2).itens }
      end

      context "when user is not a contributor" do
        let(:user) { create(:contribution, state: 'pending', project: project).user }

        it { should eq([@update]) }
      end

      context "when user is a project owner" do
        let(:user) { project.user }

        it { should have(2).itens }
      end

      context "when user is an admin" do
        let(:user) { create(:user, admin: true) }

        it { should have(2).itens }
      end

      context "when user is a guest" do
        it { should eq([@update]) }
      end
    end
  end
end
