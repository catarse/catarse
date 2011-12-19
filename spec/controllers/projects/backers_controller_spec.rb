require 'spec_helper'

describe Projects::BackersController do
  render_views

  before(:each) do
    @user = create(:user)
    @user_backer = create(:user, :name => 'Lorem Ipsum')
    @project = create(:project)
    @backer = create(:backer, :value=> 10.00, :user => @user_backer, :confirmed => true, :project => @project)
  end

  context "new" do
    context "without user" do
      it "should redirect" do
        get :new, {:locale => :pt, :project_id => @project.id}
        response.should be_redirect
      end
    end

    context "with user" do
      context "when can't back project" do
        it "when project is not visible, should redirect" do
          request.session[:user_id]=@user.id
          @project.update_attribute :visible, false
          @project.reload
          get :new, {:locale => :pt, :project_id => @project.id}

          response.should be_redirect
        end

        it "when project expired, should redirect" do
          request.session[:user_id]=@user.id
          @project.update_attribute :expires_at, 1.day.ago
          @project.reload
          get :new, {:locale => :pt, :project_id => @project.id}

          response.should be_redirect
        end

        it "when project is rejected, should redirect" do
          request.session[:user_id]=@user.id
          @project.update_attribute :rejected, true
          @project.reload
          get :new, {:locale => :pt, :project_id => @project.id}

          response.should be_redirect
        end
      end

      context "when can back project" do
        it "should see infos about the project and rewards" do
          @project.update_attributes({:rejected => false, :expires_at => 10.days.from_now, :visible => true})
          @project.reload
          request.session[:user_id]=@user.id
          get :new, {:locale => :pt, :project_id => @project.id}

          response.body.should =~ /#{I18n.t('projects.backers.new.header.title')}/
          response.body.should =~ /#{I18n.t('projects.backers.new.submit')}/
          response.body.should =~ /#{I18n.t('projects.backers.new.no_reward')}/
          response.body.should =~ /#{@project.name}/
          response.should render_template("projects/backers/new")
        end
      end
    end
  end

  context "index" do
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
end