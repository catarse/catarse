require 'spec_helper'

describe Projects::BackersController do
  render_views

  before(:each) do
    @user = create(:user)
    @user_backer = create(:user, :name => 'Lorem Ipsum')
    @project = create(:project)
    @backer = create(:backer, :value=> 10.00, :user => @user_backer, :confirmed => true, :project => @project)
  end

  shared_examples_for  "admin / owner" do
    it "should see all info from backer" do
      request.session[:user_id]=@user.id
      get :index, {:locale => :pt, :project_id => @project.id}

      ActiveSupport::JSON.decode(response.body).to_s.should =~ /R\$ 10/
      ActiveSupport::JSON.decode(response.body).to_s.should =~ /Lorem Ipsum/
    end
  end

  shared_examples_for "normal / guest" do
    it "should see filtered info about backer" do
      request.session[:user_id]=@user.id
      get :index, {:locale => :pt, :project_id => @project.id}

      ActiveSupport::JSON.decode(response.body).to_s.should_not =~ /R\$ 10/
      ActiveSupport::JSON.decode(response.body).to_s.should =~ /Lorem Ipsum/
    end
  end

  context "with admin user" do
    before(:each) do
      @user.update_attribute :admin, true
      @user.reload
    end

    it_should_behave_like "admin / owner"
  end

  context "with project owner user" do
    before(:each) do
      @project.update_attribute :user, @user
      @project.reload
    end

    it_should_behave_like "admin / owner"
  end

  context "with normal user" do
    it_should_behave_like "normal / guest"
  end

  context "guest user" do
    before(:each) do
      @user.id = nil
    end

    it_should_behave_like "normal / guest"
  end
end