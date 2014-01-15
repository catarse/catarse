require 'spec_helper'

describe Admin::ProjectsController do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  let(:current_user){ admin }

  before do
    controller.stub(:current_user).and_return(current_user)
    request.env['HTTP_REFERER'] = admin_projects_path
  end

  describe 'PUT approve' do
    let(:project) { create(:project, state: 'in_analysis') }
    subject { project.online? }

    before do
      put :approve, id: project, locale: :pt
    end

    it do
      project.reload
      should be_true
    end
  end

  describe 'PUT reject' do
    let(:project) { create(:project, state: 'in_analysis') }
    subject { project.rejected? }

    before do
      put :reject, id: project, locale: :pt
      project.reload
    end

    it { should be_true }
  end

  describe 'PUT push_to_draft' do
    let(:project) { create(:project, state: 'online') }
    subject { project.draft? }

    before do
      controller.stub(:current_user).and_return(admin)
      put :push_to_draft, id: project, locale: :pt
    end

    it do
      project.reload
      should be_true
    end
  end

  describe 'PUT push_to_trash' do
    let(:project) { create(:project, state: 'draft') }
    subject{ project.reload.deleted? }

    before do
      controller.stub(:current_user).and_return(admin)
      put :push_to_trash, id: project, locale: :pt
    end

    it{ should be_true }
  end


  describe "GET index" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :index, locale: :pt
      end
      it{ should redirect_to new_user_registration_path }
    end

    context "when I'm logged as admin" do
      before do
        get :index, locale: :pt
      end
      its(:status){ should == 200 }
    end
  end

  describe '.collection' do
    let(:project) { create(:project, name: 'Project for search') }
    context "when there is a match" do
      before do
        get :index, locale: :pt, pg_search: 'Project for search'
      end
      it{ assigns(:projects).should eq([project]) }
    end

    context "when there is no match" do
      before do
        get :index, locale: :pt, pg_search: 'Foo Bar'
      end
      it{ assigns(:projects).should eq([]) }
    end
  end

  describe "DELETE destroy" do
    let(:project) { create(:project, state: 'draft') }

    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        delete :destroy, id: project, locale: :pt
      end
      it{ should redirect_to new_user_registration_path }
    end

    context "when I'm logged as admin" do
      before do
        delete :destroy, id: project, locale: :pt
      end

      its(:status){ should redirect_to admin_projects_path }

      it 'should change state to deleted' do
        expect(project.reload.deleted?).to be_true
      end
    end
  end
end

