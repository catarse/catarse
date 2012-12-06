require 'spec_helper'

describe UpdatesController do
  let(:update){ Factory(:update) }
  let(:user){ update.project.user }
  subject{ response }

  shared_examples_for "GET updates index" do
    before{ get :index, :project_id => update.project.id, :locale => 'pt', :format => 'html' }
    its(:status){ should == 200 }
  end

  shared_examples_for "DELETE updates destroy" do
    before { delete :destroy, :project_id => update.project.id, :id => update.id, :locale => 'pt' }
    its(:status) { should == 200}
  end

  shared_examples_for "DELETE updates destroy without permission" do
    before { delete :destroy, :project_id => update.project.id, :id => update.id, :locale => 'pt' }
    its(:status) { should == 302 }
  end

  shared_examples_for "POST updates create" do
    before{ post :create, :project_id => update.project.id, :locale => 'pt', :update => {:title => 'title', :comment => 'update comment'} }
    it{ Update.where(:user_id => user.id, :project_id => update.project.id).count.should ==  1}
  end

  shared_examples_for "POST updates create without permission" do
    before{ post :create, :project_id => update.project.id, :locale => 'pt', :update => {:title => 'title', :comment => 'update comment'} }
    it{ Update.where(:user_id => user.id, :project_id => update.project.id).count.should == 0}
  end

  context 'When user is admin' do
    let(:user) { Factory(:user, admin: true) }
    before{ request.session[:user_id] = user.id }

    it_should_behave_like "GET updates index"
    it_should_behave_like "DELETE updates destroy"
    it_should_behave_like "POST updates create"
  end

  context 'When user is a guest' do
    it_should_behave_like "GET updates index"
    it_should_behave_like "DELETE updates destroy without permission"
    it_should_behave_like "POST updates create without permission"
  end

  context 'When user is project_owner' do
    before{ request.session[:user_id] = user.id }

    it_should_behave_like "GET updates index"
    it_should_behave_like "DELETE updates destroy"
    it_should_behave_like "POST updates create"
  end

  context "When user is a registered user but don't the project owner" do
    before{ request.session[:user_id] = Factory(:user).id }

    it_should_behave_like "GET updates index"
    it_should_behave_like "DELETE updates destroy without permission"
    it_should_behave_like "POST updates create without permission"
  end

end
