require 'spec_helper'

describe UpdatesController do
  let(:update){ Factory(:update) }
  let(:user){ update.project.user }
  subject{ response }
  before{ request.session[:user_id] = user.id }

  describe "GET index" do
    before{ get :index, :project_id => update.project.id, :locale => 'pt', :format => 'html' }
    its(:status){ should == 200 }
  end

  describe "DELETE destroy" do
    before{ delete :destroy, :project_id => update.project.id, :id => update.id, :locale => 'pt' }
    its(:status){ should == 200 }
  end

  describe "POST create" do
    before{ post :create, :project_id => update.project.id, :locale => 'pt', :update => {:title => 'title', :comment => 'update comment'} }
    it{ should redirect_to project_path(update.project, :anchor => 'updates') }
    it{ Update.where(:user_id => user.id, :project_id => update.project.id).count.should == 1 }
  end

end
