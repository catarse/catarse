require 'spec_helper'

describe Projects::BackersController do
  render_views
  let(:failed_project) { Factory(:project, :finished => true, :successful => false) }
  let(:project) { Factory(:project) }

  subject{ response }

  before do
    @user = Factory(:user)
    @user_backer = Factory(:user, :name => 'Lorem Ipsum')
    @backer = Factory(:backer, :value=> 10.00, :user => @user_backer, :confirmed => true, :project => project)
  end

  describe "PUT checkout" do
    context "without user" do
      it "should be redirect" do
        put :checkout, { :locale => :pt, :project_id => project.id, :id => @backer.id }
        response.should be_redirect
      end
    end

    it "when backer don't exist in current_user" do
      request.session[:user_id]=@user.id
      lambda {
        put :checkout, {:locale => :pt, :project_id => project.id, :id => @backer.id}
      }.should raise_error(ActiveRecord::RecordNotFound)
    end

    context "with user" do
      context "credits" do
        it "when user don't have credits enough" do
          request.session[:user_id]=@user_backer.id
          @backer.update_attributes({:value => 10, :credits => true})
          @backer.confirmed = false
          @backer.save!

          put :checkout, { :locale => :pt, :project_id => project.id, :id => @backer.id }

          @user_backer.reload
          @backer.reload

          @user_backer.credits.to_i.should == 0
          @backer.confirmed.should be_false

          request.flash[:failure].should == I18n.t('projects.backers.checkout.no_credits')
          response.should be_redirect
        end

        it "when user have credits enough" do
          request.session[:user_id]=@user_backer.id
          Factory(:backer, :value=> 100.00, :user => @user_backer, :confirmed => true, :project => failed_project)
          @backer.update_attributes({:value => 10, :credits => true })
          @backer.confirmed=false
          @backer.save!

          put :checkout, { :locale => :pt, :project_id => project.id, :id => @backer.id }

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
        post :review, {:locale => :pt, :project_id => project.id}
      end
      it{ should redirect_to login_path }
      it{ session[:return_to].should == "/test_path" }
    end

    context "with user" do
      it "when correct data" do
        request.session[:user_id]=@user.id
        request.session[:thank_you_id].should be_nil
        post :review, {:locale => :pt, :project_id => project.id, :backer => {
          :value => '20.00',
          :reward_id => '0',
          :anonymous => '0'
        }}
        request.session[:thank_you_id].should == project.id
        response.body =~ /#{I18n.t('projects.backers.checkout.title')}/
        response.body =~ /#{project.name}/
        response.body =~ /R\$ 20/
      end
    end
  end

  describe "GET new" do
    context "without user" do
      before{ get :new, {:locale => :pt, :project_id => project.id} }
      it{ should redirect_to login_path }
    end

    context "with user" do
      before do
        request.session[:user_id] = @user.id
      end

      context "when project.can_back? is false" do
        before do
          Project.any_instance.stubs(:can_back?).returns(false)
          get :new, {:locale => :pt, :project_id => project.id}
        end
        it{ should redirect_to root_path }
      end

      context "when project.can_back? is true and we have configured a secure review url" do
        before do 
          ::Configuration[:secure_review_host] = 'secure.catarse.me'
          Project.any_instance.stubs(:can_back?).returns(true)
          get :new, {:locale => :pt, :project_id => project.id}
        end

        it "should assign the https url to @review_url" do
          assigns(:review_url).should == review_project_backers_url(project, :host => Configuration[:secure_review_host], :protocol => 'https')
        end
      end

      context "when project.can_back? is true and we have not configured a secure review url" do
        before do 
          ::Configuration[:secure_review_host] = nil
          Project.any_instance.stubs(:can_back?).returns(true)
          get :new, {:locale => :pt, :project_id => project.id}
        end

        it{ should render_template("projects/backers/new") }

        it "should assign review_project_backers_path to @review_url" do
          assigns(:review_url).should == review_project_backers_path(project)
        end

        its(:body) { should =~ /#{I18n.t('projects.backers.new.header.title')}/ }
        its(:body) { should =~ /#{I18n.t('projects.backers.new.submit')}/ }
        its(:body) { should =~ /#{I18n.t('projects.backers.new.no_reward')}/ }
        its(:body) { should =~ /#{project.name}/ }
      end
    end
  end

  describe "GET index" do
    shared_examples_for  "admin / owner" do
      it "should see all info from backer" do
        request.session[:user_id] = @user.id
        get :index, {:locale => :pt, :project_id => project.id}

        ActiveSupport::JSON.decode(response.body).to_s.should =~ /R\$ 10/
        ActiveSupport::JSON.decode(response.body).to_s.should =~ /Lorem Ipsum/
      end
    end

    shared_examples_for "normal / guest" do
      it "should see filtered info about backer" do
        request.session[:user_id] = @user.id
        get :index, {:locale => :pt, :project_id => project.id}

        ActiveSupport::JSON.decode(response.body).to_s.should =~ /Lorem Ipsum/
      end
    end

    context "with admin user" do
      before do
        @user.admin = true
        @user.save
        @user.reload
      end

      it_should_behave_like "admin / owner"
    end

    context "with project owner user" do
      let(:project) { Factory(:project, :user => @user) }

      it_should_behave_like "admin / owner"
    end

    context "with normal user" do
      it_should_behave_like "normal / guest"
    end

    context "guest user" do
      before{ @user.id = nil }

      it_should_behave_like "normal / guest"
    end
  end
end
