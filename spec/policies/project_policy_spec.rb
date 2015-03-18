require 'rails_helper'

RSpec.describe ProjectPolicy do
  subject{ ProjectPolicy }

  shared_examples_for "create permissions" do
    it "should deny access if user is nil" do
      is_expected.not_to permit(nil, Project.new)
    end

    it "should deny access if user is not project owner" do
      is_expected.not_to permit(User.new, Project.new(user: User.new))
    end

    it "should permit access if user is project owner" do
      new_user = User.new
      is_expected.to permit(new_user, Project.new(user: new_user))
    end

    it "should permit access if user is admin" do
      admin = User.new
      admin.admin = true
      is_expected.to permit(admin, Project.new(user: User.new))
    end
  end

  describe 'UserScope' do
    describe ".resolve" do
      let(:current_user) { create(:user, admin: false) }
      let(:user) { create(:user) }

      before do
        @draft = create(:project, state: 'draft', user: user)
        @online = create(:project, state: 'online', user: user)
        @in_analysis = build(:project, state: 'in_analysis', user: user)
        @in_analysis.save(validate: false)
      end

      subject { ProjectPolicy::UserScope.new(current_user, user, user.projects).resolve.order('created_at desc') }

      context "when user is admin" do
        let(:current_user) { create(:user, admin: true) }

        it { is_expected.to have(3).itens }
      end

      context "when user is a project owner" do
        let(:current_user) { user }
        it { is_expected.to eq [@in_analysis, @online, @draft] }
      end

      context "when user is not an admin and project owner" do
        it { is_expected.to eq [@online] }
      end
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
    context "when user is nil and I want to update about_html" do
      let(:policy){ ProjectPolicy.new(nil, Project.new) }
      subject{ policy.permitted_for?(:about_html, :update) }
      it{ is_expected.to eq(false) }
    end

    context "when user is project owner and I want to update about_html" do
      let(:project){ create(:project) }
      let(:policy){ ProjectPolicy.new(project.user, project) }
      subject{ policy.permitted_for?(:about_html, :update) }
      it{ is_expected.to eq(true) }
    end
  end

  describe "#permitted?" do
    context "when user is nil" do
      let(:policy){ ProjectPolicy.new(nil, Project.new) }
      [:about_html, :video_url, :uploaded_image, :headline].each do |field|
        context "when field is #{field}" do
          subject{ policy.permitted?(field) }
          it{ is_expected.to eq(true) }
        end
      end
      context "when field is title" do
        subject{ policy.permitted?(:title) }
        it{ is_expected.to eq(false) }
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
          it{ is_expected.to eq(true) }
        end
      end
    end
  end

end
