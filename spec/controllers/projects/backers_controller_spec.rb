require 'spec_helper'

describe Projects::BackersController do
  render_views

  before(:each) do
    @user = create(:user)
    @user_backer = create(:user, :name => 'Lorem Ipsum')
    @project = create(:project)
    @backer = create(:backer, :value=> 10.00, :user => @user_backer, :confirmed => true, :project => @project)
  end

  context "with admin user" do
    before(:each) do
      @user.update_attribute :admin, true
      @user.reload
    end

    it "should see all info from backer" do
      request.session[:user_id]=@user.id
      get :index, {:locale => :pt, :project_id => @project.id}

      ActiveSupport::JSON.decode(response.body).to_s.should =~ /R\$ 10/
      ActiveSupport::JSON.decode(response.body).to_s.should =~ /Lorem Ipsum/
    end
  end

  context "with normal user" do
    it "should filtered info about backer" do
      request.session[:user_id]=@user.id
      get :index, {:locale => :pt, :project_id => @project.id}

      ActiveSupport::JSON.decode(response.body).to_s.should_not =~ /R\$ 10/
      ActiveSupport::JSON.decode(response.body).to_s.should =~ /Lorem Ipsum/
    end
  end

  context "with guest" do
  end

  context "with project owner" do
  end
end