require 'rails_helper'

RSpec.describe ProjectPostPolicy do
  subject { ProjectPostPolicy }

  shared_examples_for "create permissions" do
    it "should deny access if user is nil" do
      is_expected.not_to permit(nil, ProjectPost.new(project: create(:project)))
    end

    it "should deny access if user is not project owner" do
      is_expected.not_to permit(User.new, ProjectPost.new(project: create(:project)))
    end

    it "should permit access if user is project owner" do
      new_user = create(:user)
      is_expected.to permit(new_user, ProjectPost.new(project: create(:project, user: new_user)))
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      is_expected.to permit(admin, ProjectPost.new(project: create(:project)))
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

      %i[title comment_html exclusive].each do |field|
        it{ is_expected.not_to be_permitted(field) }
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

      %i[title comment_html exclusive].each do |field|
        it{ is_expected.to be_permitted(field) }
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
        let(:user) { create(:confirmed_contribution, project: project).user }
        it { is_expected.to eq true }
      end

      context "when user is not a contributor" do
        let(:user) { create(:pending_contribution, project: project).user }

        it { is_expected.to eq false }
      end

      context "when user is a project owner" do
        let(:user) { project.user }

        it { is_expected.to eq true }
      end

      context "when user is an admin" do
        let(:user) { create(:user, admin: true) }

        it { is_expected.to eq true }
      end

      context "when user is a guest" do
        it { is_expected.to be nil }
      end
    end

    context "when post is not exclusive" do
      let(:project_post){ create(:project_post, project: project, exclusive: false) }
      let(:policy){ ProjectPostPolicy.new(user, project_post).show? }
      subject{ policy }

      context "when user is a guest" do
        it { is_expected.to be true }
      end

    end
  end

end
