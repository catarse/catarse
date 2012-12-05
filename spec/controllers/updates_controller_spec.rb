require 'spec_helper'

describe UpdatesController do
  let(:update){ Factory(:update) }
  let(:user){ update.project.user }
  subject{ response }

  shared_examples_for "GET index" do
    before{ get :index, :project_id => update.project.id, :locale => 'pt', :format => 'html' }
    its(:status){ should == 200 }
  end

  shared_examples_for "DELETE destroy" do |status = 200|
    before { delete :destroy, :project_id => update.project.id, :id => update.id, :locale => 'pt' }
    its(:status) { should == status}
  end

  shared_examples_for "POST create" do |total_updates = 0|
    before{ post :create, :project_id => update.project.id, :locale => 'pt', :update => {:title => 'title', :comment => 'update comment'} }
    it{ Update.where(:user_id => user.id, :project_id => update.project.id).count.should == total_updates }
  end

  context 'When user is admin' do
    let(:user) { Factory(:user, admin: true) }
    before{ request.session[:user_id] = user.id }

    it_should_behave_like "GET index"

    it_should_behave_like "DELETE destroy"

    it_should_behave_like "POST create", 1
  end

  context 'When user is a guest' do
    it_should_behave_like "GET index"

    it_should_behave_like "DELETE destroy", 302

    it_should_behave_like "POST create"
  end

  context 'When user is project_owner' do
    before{ request.session[:user_id] = user.id }

    it_should_behave_like "GET index"

    it_should_behave_like "DELETE destroy"

    it_should_behave_like "POST create", 1
  end

  context "When user is a registered user but don't the project owner" do
    before{ request.session[:user_id] = Factory(:user).id }

    it_should_behave_like "GET index"

    it_should_behave_like "DELETE destroy", 302

    it_should_behave_like "POST create", 0
  end

end
