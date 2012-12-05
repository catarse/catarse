#encoding:utf-8
require 'spec_helper'

describe ProjectsController do
  before {Notification.unstub(:create_notification)}
  render_views
  subject{ response }

  shared_examples_for "access on :read :projects" do
    describe "GET ProjectsController#show [projects/1]" do
      before { get :show, id: project.id, locale: :pt}
      it { should be_success }

      context "when we have update_id in the querystring" do
        let(:project){ Factory(:project, :permalink => nil) }
        let(:update){ Factory(:update, :project => project) }
        before{ get :show, :id => project, :update_id => update.id, :locale => :pt }
        it("should assign update to @update"){ assigns(:update).should == update }
      end

      context "when we have permalink and do not pass permalink in the querystring" do
        let(:project){ Factory(:project, :permalink => 'test') }
        before{ get :show, :id => project, :locale => :pt }
        it{ should redirect_to project_by_slug_path(project.permalink) }
      end

      context "when we do not have permalink and do not pass permalink in the querystring" do
        let(:project){ Factory(:project, :permalink => nil) }
        before{ get :show, :id => project, :locale => :pt }
        it{ should be_success }
      end
    end
  end

  shared_examples_for "access on :create :projects" do
    describe "GET ProjectsController#new [projects/new]" do
      before { get :new, locale: :pt }
      it { should be_success }
    end
  end

  shared_examples_for "no access on :create :projects" do
    describe "GET ProjectsController#new [projects/new]" do
      before { get :new, locale: :pt }
      it { should_not be_success }
    end
  end

  shared_examples_for "access on :update :projects" do
    describe "PUT ProjectsController#update [projects/1]" do
      before { put :update, id: project.id, project: { name: 'My Updated Title' },locale: :pt }
      it { 
        project.reload
        project.name.should == 'My Updated Title' 
      }
    end
  end

  shared_examples_for "no access on :update :projects" do
    describe "PUT ProjectsController#update [projects/1]" do
      before { put :update, id: project.id, project: { name: 'My Updated Title' },locale: :pt }
      it { 
        project.reload
        project.name.should == 'Foo bar' 
      }
    end
  end

  shared_examples_for "access on :delete :projects" do
    describe "DELETE ProjectsController#destroy [projects/1]" do
      before { delete :destroy, id: project.id, locale: :pt }
      it { Project.all.include?(project).should be_false }
    end
  end

  shared_examples_for "no access on :delete :projects" do
    describe "DELETE ProjectsController#destroy [projects/1]" do
      before { delete :destroy, id: project.id, locale: :pt }
      it { Project.all.include?(project).should be_true }
    end
  end

  context "When current_user is a guest" do
    let(:project) { Factory(:project, permalink: nil) } 

    before do
      controller.stubs(:current_user).returns(nil)
    end

    it_should_behave_like "access on :read :projects"

    it_should_behave_like "no access on :create :projects"

    it_should_behave_like "no access on :update :projects"

    it_should_behave_like "no access on :delete :projects"
  end

  context "When current_user is a project owner" do
    let(:project) { Factory(:project, permalink: nil) } 

    before do
      controller.stubs(:current_user).returns(project.user)
    end

    it_should_behave_like "access on :read :projects"

    it_should_behave_like "access on :create :projects"

    it_should_behave_like "access on :update :projects"

    it_should_behave_like "no access on :delete :projects"
  end

  context "When current_user is admin" do
    let(:project) { Factory(:project, permalink: nil) } 

    before do
      controller.stubs(:current_user).returns(Factory(:user, admin: true))
    end

    it_should_behave_like "access on :read :projects"

    it_should_behave_like "access on :create :projects"

    it_should_behave_like "access on :update :projects"

    it_should_behave_like "access on :delete :projects"
  end

  context "When current_user is a registered user" do
    let(:project) { Factory(:project, permalink: nil) } 

    before do
      controller.stubs(:current_user).returns(Factory(:user, admin: false))
    end

    it_should_behave_like "access on :read :projects"

    it_should_behave_like "access on :create :projects"

    it_should_behave_like "no access on :update :projects"

    it_should_behave_like "no access on :delete :projects"
  end

  #describe "GET new" do
    #let(:user){ Factory(:user) }
    #context "when I'm not logged in" do
      #before{ get :new, :locale => :pt }
      #it{ should redirect_to(login_path) }
    #end

    #context "when I'm logged in" do
      #before do
        #controller.stubs(:current_user).returns(user)
        #get :new, :locale => :pt
      #end
      #it{ should be_success }
    #end

  #end

  #describe "POST send_mail" do
    #let(:project){ Factory(:project) }
    #Factory(:notification_type, :name => 'project_received')
    #let(:name){ project.name }
    #let(:user){ project.user }

    #before do
      #controller.stubs(:current_user).returns(user)
      #Notification.expects(:create_notification).with(:project_received, user)
      #post :send_mail, :locale => :pt
    #end

    #it{ should redirect_to root_path }
  #end
end
