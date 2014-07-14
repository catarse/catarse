require 'spec_helper'

describe Projects::PostsController do
  let(:project_post){ FactoryGirl.create(:project_post) }
  let(:current_user){ nil }
  before{ controller.stub(:current_user).and_return(current_user) }
  subject{ response }

  describe "GET index" do
    before{ get :index, project_id: project_post.project.id, locale: 'pt', format: 'html' }
    its(:status){ should == 200 }
  end

  describe "DELETE destroy" do
    before { delete :destroy, project_id: project_post.project.id, id: project_post.id, locale: 'pt' }
    context 'When user is a guest' do
      its(:status) { should == 302 }
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user){ FactoryGirl.create(:user) }
      its(:status) { should == 302 }
    end

    context 'When user is admin' do
      let(:current_user) { FactoryGirl.create(:user, admin: true) }
      its(:status) { should == 200}
    end

    context 'When user is project_owner' do
      let(:current_user) { project_post.project.user }
      its(:status) { should == 200}
    end
  end

  describe "POST create" do
    before{ post :create, project_id: project_post.project.id, locale: 'pt', project_post: {title: 'title', comment: 'project_post comment'} }
    context 'When user is a guest' do
      it{ ProjectPost.where(project_id: project_post.project.id).count.should == 1 }
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user){ create(:project).user }
      it{ ProjectPost.where(project_id: project_post.project.id).count.should == 1 }
    end

    context 'When user is admin' do
      let(:current_user) { FactoryGirl.create(:user, admin: true) }
      it{ ProjectPost.where(project_id: project_post.project.id).count.should ==  2 }
    end

    context 'When user is project_owner' do
      let(:current_user) { project_post.project.user }
      it{ ProjectPost.where(project_id: project_post.project.id).count.should ==  2 }
    end
  end
end
