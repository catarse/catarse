require 'spec_helper'

describe Projects::BackersController do
  render_views

  subject{ response }

  before do
    @user = create(:user)
    @user_backer = create(:user, :name => 'Lorem Ipsum')
    @project = create(:project)
    @backer = create(:backer, :value=> 10.00, :user => @user_backer, :confirmed => true, :project => @project)
  end

  describe "PUT checkout" do
    context "without user" do
      it "should be redirect" do
        put :checkout, { :locale => :pt, :project_id => @project.id, :id => @backer.id }
        response.should be_redirect
      end
    end

    it "when backer don't exist in current_user" do
      request.session[:user_id]=@user.id
      lambda {
        put :checkout, {:locale => :pt, :project_id => @project.id, :id => @backer.id}
      }.should raise_error(ActiveRecord::RecordNotFound)
    end

    context "with user" do
      context "credits" do
        it "when user don't have credits enough" do
          request.session[:user_id]=@user_backer.id
          @user_backer.update_attribute(:credits, 8)
          @backer.update_attributes({:value => 10, :credits => true, :confirmed => false})

          put :checkout, { :locale => :pt, :project_id => @project.id, :id => @backer.id }

          @user_backer.reload
          @backer.reload

          @user_backer.credits.to_i.should == 8
          @backer.confirmed.should be_false

          request.flash[:failure].should == I18n.t('projects.backers.checkout.no_credits')
          response.should be_redirect
        end

        it "when user have credits enough" do
          request.session[:user_id]=@user_backer.id
          @user_backer.update_attribute(:credits, 100)
          @backer.update_attributes({:value => 10, :credits => true, :confirmed => false})

          put :checkout, { :locale => :pt, :project_id => @project.id, :id => @backer.id }

          @user_backer.reload
          @backer.reload

          @user_backer.credits.to_i.should == 90
          @backer.confirmed.should be_true

          request.flash[:success].should == I18n.t('projects.backers.checkout.success')
          response.should be_redirect
        end
      end
    end
  end

  describe "POST review" do
    context "without user" do
      before do 
        request.env['REQUEST_URI'] = "/test_path"
        post :review, {:locale => :pt, :project_id => @project.id}
      end
      it{ should redirect_to login_path }
      it{ session[:return_to].should == "/test_path" }
    end

    context "with user" do
      it "when correct data" do
        request.session[:user_id]=@user.id
        request.session[:thank_you_id].should be_nil
        post :review, {:locale => :pt, :project_id => @project.id, :backer => {
          :value => '20.00',
          :reward_id => '0',
          :anonymous => '0'
        }}
        request.session[:thank_you_id].should == @project.id
        response.body =~ /#{I18n.t('projects.backers.checkout.title')}/
        response.body =~ /#{@project.name}/
        response.body =~ /R\$ 20/
      end
    end
  end

  describe "GET new" do
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

  describe "GET index" do
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

        ActiveSupport::JSON.decode(response.body).to_s.should =~ /Lorem Ipsum/
      end
    end

    context "with admin user" do
      before do
        @user.update_attribute :admin, true
        @user.reload
      end

      it_should_behave_like "admin / owner"
    end

    context "with project owner user" do
      before do
        @project.update_attribute :user, @user
        @project.reload
      end

      it_should_behave_like "admin / owner"
    end

    context "with normal user" do
      it_should_behave_like "normal / guest"
    end

    context "guest user" do
      before do
        @user.id = nil
      end

      it_should_behave_like "normal / guest"
    end
  end
end
