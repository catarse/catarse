require 'spec_helper'

describe UpdatesController do
  subject{ response }
  describe "GET index" do
    before do
      @update = Factory(:update)
      get :index, :project_id => @update.project.id, :locale => 'pt', :format => 'html'
    end
    its(:status){ should == 200 }
  end

  describe "DELETE destroy" do
    before do
      @update = Factory(:update)
      delete :destroy, :project_id => @update.project.id, :id => @update.id, :locale => 'pt'
    end
    its(:status){ should == 200 }
  end

  describe "POST create" do
    let(:user){ Factory(:user) }
    before do
      request.session[:user_id] = user.id
      @project = Factory(:project)
      post :create, :project_id => @project.id, :locale => 'pt', :update => {:title => 'title', :comment => 'update comment'}
    end
    it{ should redirect_to project_updates_path(@project) }
    it{ Update.where(:user_id => user.id, :project_id => @project.id).count.should == 1 }
  end

end
