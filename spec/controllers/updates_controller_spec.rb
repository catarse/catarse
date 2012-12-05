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

  shared_examples_for "DELETE updates" do |raise_ex = false, exception = CanCan::Unauthorized |
    describe "DELETE destroy" do
      if raise_ex
        it 'should raise a cancan exception' do
          lambda {
            delete :destroy, :project_id => update.project.id, :id => update.id, :locale => 'pt' 
          }.should raise_exception exception
        end
      else
        before { delete :destroy, :project_id => update.project.id, :id => update.id, :locale => 'pt' }
        its(:status) { should == 200}
      end
    end
  end

  shared_examples_for "CREATE updates" do |raise_ex = false, exception = CanCan::Unauthorized|
    describe "POST create" do
      if raise_ex
        it 'should raise a cancan exception' do
          lambda{ 
            post :create, :project_id => update.project.id, :locale => 'pt', :update => {:title => 'title', :comment => 'update comment'} 
          }.should raise_exception exception
        end
      else
        before{ post :create, :project_id => update.project.id, :locale => 'pt', :update => {:title => 'title', :comment => 'update comment'} }
        it{ should redirect_to project_path(update.project, :anchor => 'updates') }
        it{ Update.where(:user_id => user.id, :project_id => update.project.id).count.should == 1 }
      end
    end
  end

  context 'When user is admin' do
    let(:user) { Factory(:user, admin: true) }
    before{ request.session[:user_id] = user.id }

    it_should_behave_like "READ updates"

    it_should_behave_like "DELETE updates"

    it_should_behave_like "CREATE updates"
  end

  context 'When user is a guest' do
    it_should_behave_like "READ updates"

    it_should_behave_like "DELETE updates", true, CanCan::Unauthorized

    it_should_behave_like "CREATE updates", true, CanCan::Unauthorized
  end

  context 'When user is project_owner' do
    before{ request.session[:user_id] = user.id }

    it_should_behave_like "READ updates"

    it_should_behave_like "DELETE updates"

    it_should_behave_like "CREATE updates"
  end

  context "When user is a registered user but don't the project owner" do
    before{ request.session[:user_id] = Factory(:user).id }

    it_should_behave_like "READ updates"

    it_should_behave_like "DELETE updates", true, CanCan::Unauthorized

    it_should_behave_like "CREATE updates", true, CanCan::Unauthorized
  end

end
