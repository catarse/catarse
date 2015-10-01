require 'rails_helper'

RSpec.describe Projects::PostsController, type: :controller do
  let(:project_post){ FactoryGirl.create(:project_post) }
  let(:current_user){ nil }
  before{ allow(controller).to receive(:current_user).and_return(current_user) }
  subject{ response }

  describe "DELETE destroy" do
    before { delete :destroy, project_id: project_post.project.id, id: project_post.id, locale: 'pt' }
    context 'When user is a guest' do
      its(:status) { should == 302 }
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user){ FactoryGirl.create(:user) }
      its(:status) { should == 302 }
      it { is_expected.to redirect_to root_path }
    end

    context 'When user is admin' do
      let(:current_user) { FactoryGirl.create(:user, admin: true) }
      its(:status) { should == 302}
      it { is_expected.to redirect_to edit_project_path(project_post.project, anchor: 'posts') }
    end

    context 'When user is project_owner' do
      let(:current_user) { project_post.project.user }
      its(:status) { should == 302}
      it { is_expected.to redirect_to edit_project_path(project_post.project, anchor: 'posts') }
    end
  end
end
