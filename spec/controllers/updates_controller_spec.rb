require 'spec_helper'

describe UpdatesController do
  let(:update){ Factory(:update) }
  let(:user){ update.project.user }
  subject{ response }

  shared_examples_for "READ updates" do
    describe "GET index" do
      before{ get :index, :project_id => update.project.id, :locale => 'pt', :format => 'html' }
      its(:status){ should == 200 }
    end
  end

  shared_examples_for "DELETE updates" do |status = 200|
    describe "DELETE destroy" do
      before { delete :destroy, :project_id => update.project.id, :id => update.id, :locale => 'pt' }
      its(:status) { should == status}
    end
  end

  shared_examples_for "CREATE updates" do |total_updates = 0|
    describe "POST create" do
      before{ post :create, :project_id => update.project.id, :locale => 'pt', :update => {:title => 'title', :comment => 'update comment'} }
      it{ Update.where(:user_id => user.id, :project_id => update.project.id).count.should == total_updates }
    end
  end

  context 'When user is admin' do
    let(:user) { Factory(:user, admin: true) }
    before{ request.session[:user_id] = user.id }

    it_should_behave_like "READ updates"

    it_should_behave_like "DELETE updates"

    it_should_behave_like "CREATE updates", 1
  end

  context 'When user is a guest' do
    it_should_behave_like "READ updates"

    it_should_behave_like "DELETE updates", 302

    it_should_behave_like "CREATE updates"
  end

  context 'When user is project_owner' do
    before{ request.session[:user_id] = user.id }

    it_should_behave_like "READ updates"

    it_should_behave_like "DELETE updates"

    it_should_behave_like "CREATE updates", 1
  end

  context "When user is a registered user but don't the project owner" do
    before{ request.session[:user_id] = Factory(:user).id }

    it_should_behave_like "READ updates"

    it_should_behave_like "DELETE updates", 302

    it_should_behave_like "CREATE updates", 0
  end

end
